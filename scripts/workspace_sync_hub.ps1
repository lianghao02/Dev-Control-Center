[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [ValidateSet('Menu', 'Auto', 'Pull', 'Push', 'SyncAI', 'Scan')]
    [string]$Action = 'Menu'
)

$ErrorActionPreference = 'Continue'
Set-StrictMode -Off
. (Join-Path $PSScriptRoot 'lib\bootstrap.ps1')
. (Join-Path $PSScriptRoot 'lib\git-status.ps1')

$homeRepo = Split-Path -Parent $PSScriptRoot
$projectPowerShell = Get-HomePowerShell
if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) { $DevelopmentRoot = Get-HomeDevelopmentRoot $homeRepo }
$devRoot = [IO.Path]::GetFullPath($DevelopmentRoot)
$manifestPath = Join-Path $homeRepo 'development-repositories.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "找不到專案清冊：$manifestPath" }
$repositories = @((Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).repositories)

function Get-StateColor([string]$State) {
    switch ($State) {
        'Synced' { 'Green' }; 'Ahead' { 'Magenta' }; 'Behind' { 'Cyan' }
        'Modified' { 'Yellow' }; 'Diverged' { 'Red' }; 'Missing' { 'DarkYellow' }
        default { 'Red' }
    }
}

function Write-ProjectState([object]$Status) {
    $symbol = switch ($Status.State) {
        'Synced' { '✓' }; 'Ahead' { '↑' }; 'Behind' { '↓' }; 'Modified' { '⚠' }
        'Diverged' { '↕' }; 'Missing' { '?' }; default { '✕' }
    }
    Write-Host ("{0,-38} {1} {2}" -f $Status.Name, $symbol, $Status.Detail) -ForegroundColor (Get-StateColor $Status.State)
}

function Get-WorkspaceStatus {
    Write-Host '=================================================================' -ForegroundColor Cyan
    Write-Host '🔍 【專案狀態掃描】只讀取 Git 狀態，不改寫工作檔案' -ForegroundColor Yellow
    Write-Host "📁 【工作目錄】$devRoot" -ForegroundColor Gray
    Write-Host '-----------------------------------------------------------------' -ForegroundColor Cyan
    $results = New-Object 'System.Collections.Generic.List[object]'
    $index = 0
    foreach ($repository in $repositories) {
        $index++
        $name = [string]$repository.folder
        $path = Join-Path $devRoot $name
        $status = Get-ManagedRepositoryStatus -RepositoryPath $path
        if ($status.State -notin @('Missing', 'Error')) {
            $safePath = $path.Replace('\', '/')
            $null = @(git -c "safe.directory=$safePath" -C $path fetch origin --prune --quiet 2>$null)
            if ($LASTEXITCODE -ne 0) {
                $status.State = 'Error'; $status.Detail = '無法取得遠端狀態；請檢查網路或 origin'
            } else {
                $status = Get-ManagedRepositoryStatus -RepositoryPath $path
            }
        }
        $status | Add-Member -NotePropertyName Index -NotePropertyValue $index
        $status | Add-Member -NotePropertyName Name -NotePropertyValue $name
        $results.Add($status)
        Write-ProjectState $status
    }
    Write-Host '-----------------------------------------------------------------' -ForegroundColor Cyan
    $summary = $results | Group-Object State | ForEach-Object { "{0}: {1}" -f $_.Name, $_.Count }
    Write-Host ("📊 【狀態摘要】{0}" -f ($summary -join ' | ')) -ForegroundColor White
    Write-Host '=================================================================' -ForegroundColor Cyan
    return $results.ToArray()
}

function Invoke-PullAll([object[]]$ScanList) {
    foreach ($item in $ScanList) {
        if ($item.State -ne 'Behind') {
            if ($item.State -in @('Modified', 'Diverged', 'Error')) { Write-Host "🛡️  $($item.Name)：$($item.Detail)" -ForegroundColor Yellow }
            continue
        }
        Write-Host "⏳ 正在安全快轉：$($item.Name) ($($item.Detail))" -ForegroundColor Yellow
        $safePath = $item.Path.Replace('\', '/')
        $null = @(git -c "safe.directory=$safePath" -C $item.Path merge --ff-only '@{upstream}' 2>$null)
        if ($LASTEXITCODE -eq 0) { Write-Host "✅ $($item.Name)：已完成安全快轉" -ForegroundColor Green }
        else { Write-Host "❌ $($item.Name)：安全快轉失敗，未自動合併。請先檢查 git status。" -ForegroundColor Red }
    }
}

function Invoke-PushExistingCommits([object[]]$ScanList) {
    foreach ($item in $ScanList) {
        if ($item.State -ne 'Ahead') {
            if ($item.State -in @('Modified', 'Behind', 'Diverged', 'Error')) { Write-Host "🛡️  $($item.Name)：$($item.Detail)；僅 Push 模式未進行任何提交或修改。" -ForegroundColor Yellow }
            continue
        }
        Write-Host "⏳ 正在推送既有提交：$($item.Name) ($($item.Detail))" -ForegroundColor Yellow
        $safePath = $item.Path.Replace('\', '/')
        $null = @(git -c "safe.directory=$safePath" -C $item.Path push 2>$null)
        if ($LASTEXITCODE -eq 0) { Write-Host "✅ $($item.Name)：既有提交已推送" -ForegroundColor Green }
        else { Write-Host "❌ $($item.Name)：推送失敗；未建立新提交。" -ForegroundColor Red }
    }
}

function Invoke-DeployAgentConfiguration {
    $syncScript = Join-Path $homeRepo 'scripts\sync_codex.ps1'
    if (-not (Test-Path -LiteralPath $syncScript -PathType Leaf)) { Write-Host '❌ 找不到 Agent 設定部署腳本。' -ForegroundColor Red; return }
    Write-Host '🔀 正在部署受管 Agent 設定與 Skills（不覆寫未受管或已修改目標）...' -ForegroundColor Yellow
    & $projectPowerShell -NoProfile -ExecutionPolicy Bypass -File $syncScript -Execute
    if ($LASTEXITCODE -ne 0) { Write-Host '❌ Agent 設定未完成部署；請依上方訊息處理受保護目標。' -ForegroundColor Red }
}

$current = Get-WorkspaceStatus
switch ($Action) {
    'Auto' { Invoke-PullAll $current; Invoke-DeployAgentConfiguration; Invoke-PushExistingCommits (Get-WorkspaceStatus); break }
    'Pull' { Invoke-PullAll $current; break }
    'Push' { Invoke-PushExistingCommits $current; break }
    'SyncAI' { Invoke-DeployAgentConfiguration; break }
    'Scan' { break }
    default {
        Write-Host ''
        Write-Host '  [1] ⚡ 智慧同步：安全 Pull → 部署受管 Agent 設定 → 僅 Push 既有提交' -ForegroundColor Yellow
        Write-Host '  [2] ⬇️  僅安全 Pull（只處理 Behind 且工作目錄乾淨的專案）'
        Write-Host '  [3] ⬆️  僅 Push 既有提交（不執行 git add 或 git commit）'
        Write-Host '  [4] 🔀 部署受管 AI 憲法與 Skills（保護個人修改）'
        Write-Host '  [0] 離開'
        $choice = (Read-Host '請輸入選項 (0-4)').Trim()
        switch ($choice) {
            '1' { Invoke-PullAll $current; Invoke-DeployAgentConfiguration; Invoke-PushExistingCommits (Get-WorkspaceStatus) }
            '2' { Invoke-PullAll $current }
            '3' { Invoke-PushExistingCommits $current }
            '4' { Invoke-DeployAgentConfiguration }
            default { Write-Host '已離開，未執行任何寫入操作。' -ForegroundColor Gray }
        }
    }
}
