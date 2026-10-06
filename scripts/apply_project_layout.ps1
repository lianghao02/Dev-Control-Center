[CmdletBinding()]
param([switch]$Execute)

# 預設僅預覽；只接受已盤點且逐檔驗證的清冊，不接受任意路徑參數。
$ErrorActionPreference = 'Stop'
$center = Split-Path $PSScriptRoot -Parent
$workspace = [IO.Path]::GetFullPath((Split-Path $center -Parent)).TrimEnd('\')
$report = Join-Path $center 'docs\project-layout'
$plan = Get-Content -LiteralPath (Join-Path $report 'operations.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$utf8 = New-Object Text.UTF8Encoding($false)
$journal = [Collections.Generic.List[object]]::new()

function Resolve-SafePath([string]$Relative) {
    if ([IO.Path]::IsPathRooted($Relative)) { throw "清冊不得包含絕對路徑：$Relative" }
    $path = [IO.Path]::GetFullPath((Join-Path $workspace $Relative))
    if (-not $path.StartsWith($workspace + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "目標超出工作區：$Relative"
    }
    $parts = $path.Substring($workspace.Length + 1).Split('\')
    if ($parts.Count -lt 2 -or ($parts | Where-Object { $_ -in @('.git','.venv','.venv-pdf','python_embed','node_modules') })) {
        throw "拒絕操作專案根目錄或受保護環境：$Relative"
    }
    $ancestor = $path
    while ($ancestor -and $ancestor.Length -gt $workspace.Length) {
        if (Test-Path -LiteralPath $ancestor) {
            $item = Get-Item -LiteralPath $ancestor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "目標含目錄連結：$ancestor" }
        }
        $ancestor = Split-Path $ancestor -Parent
    }
    return $path
}

function Get-Inventory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "目標已不存在：$Path" }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "目標為連結：$Path" }
    $files = [Collections.Generic.List[object]]::new()
    if (-not $item.PSIsContainer) { $files.Add($item) }
    else {
        $queue = [Collections.Generic.Queue[string]]::new()
        $queue.Enqueue($Path)
        while ($queue.Count) {
            foreach ($child in Get-ChildItem -LiteralPath $queue.Dequeue() -Force) {
                if ($child.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "拒絕遍歷連結：$($child.FullName)" }
                if ($child.PSIsContainer) { $queue.Enqueue($child.FullName) } else { $files.Add($child) }
            }
        }
    }
    $hashes = @{}
    $bytes = 0L
    foreach ($file in $files) {
        $key = if ($item.PSIsContainer) { $file.FullName.Substring($Path.Length + 1).Replace('\','/') } else { '.' }
        $hashes[$key] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $bytes += $file.Length
    }
    return @{ Hashes=$hashes; Bytes=$bytes; Files=$files.Count }
}

function Assert-Fingerprint([string]$Path, $Action) {
    $actual = Get-Inventory $Path
    $expected = @($Action.fingerprints.PSObject.Properties)
    if ($actual.Files -ne $Action.files -or $actual.Bytes -ne $Action.bytes -or $actual.Files -ne $expected.Count) {
        throw "盤點後檔案數／容量已變動，停止：$Path"
    }
    foreach ($property in $expected) {
        if ($actual.Hashes[$property.Name] -ne $property.Value) { throw "盤點後檔案內容已變動，停止：$Path / $($property.Name)" }
    }
}

function Assert-Protected {
    foreach ($property in $plan.protected.PSObject.Properties) {
        # 保護清冊可以指向環境檔，但不會呼叫搬移／刪除函式。
        $path = [IO.Path]::GetFullPath((Join-Path $workspace $property.Name))
        if (-not $path.StartsWith($workspace + '\', [StringComparison]::OrdinalIgnoreCase)) { throw '保護路徑超出工作區' }
        if (-not (Test-Path -LiteralPath $path) -or
            (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $property.Value) {
            throw "受保護檔案已變動：$($property.Name)"
        }
    }
}

function Save-Journal {
    [IO.File]::WriteAllText((Join-Path $report 'execution.json'),
        (ConvertTo-Json -InputObject @($journal.ToArray()) -Depth 12), $utf8)
}

foreach ($action in $plan.actions) {
    Write-Output ("{0}: {1} ({2} 個檔案，{3:N2} MiB)" -f $action.action,$action.source,$action.files,($action.bytes/1MB))
}
Write-Output "虛構歷史紀錄：$(@($plan.history.entries).Count) 筆"
if (-not $Execute) { Write-Output '尚未搬移或刪除；實際執行須明確指定 -Execute。'; return }
if (Test-Path -LiteralPath (Join-Path $report 'execution.json')) { throw '已有執行紀錄，請先檢查結果；禁止盲目重複執行。' }

# 先驗證所有目標及現行資料，再開始第一個動作。
Assert-Protected
$processPaths = @(Get-CimInstance Win32_Process | Where-Object ExecutablePath | Select-Object -ExpandProperty ExecutablePath)
foreach ($action in $plan.actions) {
    if ($action.action -notin @('move','remove')) { throw '不支援的清冊動作' }
    $source = Resolve-SafePath $action.source
    Assert-Fingerprint $source $action
    foreach ($processPath in $processPaths) {
        if ($processPath.Equals($source, [StringComparison]::OrdinalIgnoreCase) -or
            $processPath.StartsWith($source + '\', [StringComparison]::OrdinalIgnoreCase)) {
            throw "目標仍有執行中的程式，保留並停止：$($action.source)"
        }
    }
    if ($action.action -eq 'move') {
        $destination = Resolve-SafePath $action.destination
        if (Test-Path -LiteralPath $destination) { throw "搬移目標已存在，禁止覆寫：$destination" }
    }
}
$indexPath = Resolve-SafePath '15_chainflow-inspector/history/history_index.json'
if ((Get-FileHash -LiteralPath $indexPath).Hash.ToLowerInvariant() -ne $plan.history.index_sha256) { throw '歷史索引已變動，停止' }
$index = @(Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json)
foreach ($entry in $plan.history.entries) {
    if ([IO.Path]::GetFileName($entry.snapshot_file) -ne $entry.snapshot_file) { throw '歷史快照路徑不合法' }
    $path = Resolve-SafePath ('15_chainflow-inspector/history/' + $entry.snapshot_file)
    if ((Get-FileHash -LiteralPath $path).Hash.ToLowerInvariant() -ne $entry.sha256) { throw '虛構快照內容已變動，停止' }
    if (@($index | Where-Object { $_.id -eq $entry.id -and $_.snapshot_file -eq $entry.snapshot_file }).Count -ne 1) { throw '索引項目不唯一' }
}

try {
    foreach ($action in $plan.actions) {
        $source = Resolve-SafePath $action.source
        Assert-Fingerprint $source $action
        if ($action.action -eq 'move') {
            $destination = Resolve-SafePath $action.destination
            $null = New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force
            Move-Item -LiteralPath $source -Destination $destination
            Assert-Fingerprint $destination $action
        } else {
            Remove-Item -LiteralPath $source -Recurse -Force
        }
        $journal.Add([pscustomobject]@{action=$action.action;source=$action.source;destination=$action.destination;
            files=$action.files;bytes=$action.bytes;status='completed';time=(Get-Date).ToString('o')})
        Save-Journal
    }
    $emptyConfig = Resolve-SafePath '00_Dev-Control-Center/config'
    if ((Test-Path -LiteralPath $emptyConfig) -and @(Get-ChildItem -LiteralPath $emptyConfig -Force).Count -eq 0) {
        Remove-Item -LiteralPath $emptyConfig
        $journal.Add([pscustomobject]@{action='remove-empty';source='00_Dev-Control-Center/config';files=0;bytes=0;status='completed'})
        Save-Journal
    }
    # 索引先保留可還原副本；只移除已證實的測試 ID，其他物件內容原封不動。
    $safety = Resolve-SafePath '00_Dev-Control-Center/artifacts/layout-safety'
    $null = New-Item -ItemType Directory -Path $safety -Force
    $backup = Join-Path $safety 'history_index.before.json'
    Copy-Item -LiteralPath $indexPath -Destination $backup
    $ids = @($plan.history.entries | ForEach-Object id)
    $remaining = @($index | Where-Object { $_.id -notin $ids })
    $temporary = Resolve-SafePath '15_chainflow-inspector/history/history_index.layout.tmp'
    if (Test-Path -LiteralPath $temporary) { throw '暫存索引已存在，禁止覆寫' }
    # 由既有專案直譯器保留 JSON 字串型別，避免 PowerShell 自動轉換日期欄位。
    $filterCode = @'
import json, sys
from pathlib import Path
index = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
plan = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
ids = {item["id"] for item in plan["history"]["entries"]}
print(json.dumps([item for item in index if item["id"] not in ids], ensure_ascii=False, indent=2))
'@
    $python = Join-Path $workspace '15_chainflow-inspector\.venv\Scripts\python.exe'
    $filteredJson = & $python -X utf8 -B -s -c $filterCode $indexPath (Join-Path $report 'operations.json')
    if ($LASTEXITCODE -ne 0) { throw '索引轉換失敗；尚未移除任何歷史紀錄' }
    [IO.File]::WriteAllText($temporary, ($filteredJson -join "`n"), $utf8)
    Move-Item -LiteralPath $temporary -Destination $indexPath -Force
    $historyBytes = 0L
    foreach ($entry in $plan.history.entries) {
        $path = Resolve-SafePath ('15_chainflow-inspector/history/' + $entry.snapshot_file)
        $historyBytes += (Get-Item -LiteralPath $path).Length
        Remove-Item -LiteralPath $path
    }
    $after = @(Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json)
    if ((ConvertTo-Json -InputObject $after -Depth 100 -Compress) -ne
        (ConvertTo-Json -InputObject $remaining -Depth 100 -Compress)) { throw '保留的歷史索引核對失敗' }
    $journal.Add([pscustomobject]@{action='remove-synthetic-history';source='15_chainflow-inspector/history';
        files=$ids.Count;bytes=$historyBytes;retained=$remaining.Count;status='completed'})
    Save-Journal
    Assert-Protected
    Write-Output '清冊執行完成；搬移雜湊與受保護檔案核對通過。'
} catch {
    $journal.Add([pscustomobject]@{action='failure';status='stopped';reason=$_.Exception.Message})
    Save-Journal
    throw
}
