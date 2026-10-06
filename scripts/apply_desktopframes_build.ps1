[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$BinaryDir,
    [switch]$Apply
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$center = Split-Path -Parent $PSScriptRoot
$workspace = Split-Path -Parent $center
$repo = Join-Path $workspace 'DesktopFramesPlus'
$target = (Resolve-Path -LiteralPath (Join-Path $repo 'dist/DesktopFramesPlus')).Path
$source = (Resolve-Path -LiteralPath $BinaryDir).Path
if ($source -eq $target) { throw '來源不可與更新目錄相同。' }
& (Join-Path $repo 'tools/package-release.ps1') -BinaryDir $source -CheckOnly
if (Get-Process -Name 'Desktop Frames' -ErrorAction SilentlyContinue) { throw '請先正常結束 Desktop Frames；更新不會強制關閉程序。' }
$files = @(Get-ChildItem -LiteralPath $source -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($source.Length + 1)
    $relative -match '^(Desktop Frames\.(exe|dll|pdb|deps\.json|runtimeconfig\.json)|NAudio(?:\.[A-Za-z]+)?\.dll|Newtonsoft\.Json\.dll|[a-z]{2}(?:-[A-Za-z]+)?\\Desktop Frames\.resources\.dll)$'
})
foreach ($required in 'Desktop Frames.exe','Desktop Frames.dll','Desktop Frames.deps.json','Desktop Frames.runtimeconfig.json','Newtonsoft.Json.dll') {
    if ($files.Name -notcontains $required) { throw "缺少必要程式檔：$required" }
}
function Get-Manifest([string]$directory) {
    $result = @{}
    Get-ChildItem -LiteralPath $directory -Recurse -File | ForEach-Object {
        $result[$_.FullName.Substring($directory.Length + 1)] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $result
}
$before = Get-Manifest $target
$plan = @($files | ForEach-Object {
    [pscustomobject]@{ Path=$_.FullName.Substring($source.Length + 1); SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
})
$plan | Format-Table -AutoSize
if (-not $Apply) { Write-Output '僅預覽；未變更成品。使用 -Apply 才會備份與套用。'; return }
$session = Join-Path $center ('artifacts/new-build-acceptance-20261006/update-' + [guid]::NewGuid().ToString('N'))
$backup = Join-Path $session 'before'
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Get-ChildItem -LiteralPath $target -Force | Copy-Item -Destination $backup -Recurse -Force
$before | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $session 'before.json') -Encoding UTF8
$plan | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $session 'plan.json') -Encoding UTF8
$copied = @()
try {
    $backupHashes = Get-Manifest $backup
    foreach ($relative in $before.Keys) {
        if ($backupHashes[$relative] -ne $before[$relative]) { throw "備份核對失敗：$relative" }
    }
    if (Get-Process -Name 'Desktop Frames' -ErrorAction SilentlyContinue) { throw '備份期間程式已啟動，停止更新。' }
    foreach ($entry in $plan) {
        $destination = Join-Path $target $entry.Path
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        $copied += $entry.Path
        Copy-Item -LiteralPath (Join-Path $source $entry.Path) -Destination $destination -Force
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $entry.SHA256) { throw "更新核對失敗：$($entry.Path)" }
    }
    $after = Get-Manifest $target
    $protected = @($before.Keys | Where-Object { $plan.Path -notcontains $_ })
    foreach ($relative in $protected) {
        if ($after[$relative] -ne $before[$relative]) { throw "資料保護核對失敗：$relative" }
    }
    [pscustomobject]@{ UpdatedFiles=$plan.Count; ProtectedFiles=$protected.Count; DataUnchanged=$true; Backup=$backup; Version=[Reflection.AssemblyName]::GetAssemblyName((Join-Path $target 'Desktop Frames.dll')).Version.ToString() } |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $session 'result.json') -Encoding UTF8
    Write-Output "套用完成；完整備份與驗證證據：$session"
}
catch {
    # 只還原本次套用過的程式檔；不覆寫 Profiles 或活動中的使用者資料。
    foreach ($relative in $copied) {
        $saved = Join-Path $backup $relative
        $destination = Join-Path $target $relative
        if (Test-Path -LiteralPath $saved -PathType Leaf) { Copy-Item -LiteralPath $saved -Destination $destination -Force }
        elseif (Test-Path -LiteralPath $destination -PathType Leaf) { Remove-Item -LiteralPath $destination -Force }
    }
    throw
}
