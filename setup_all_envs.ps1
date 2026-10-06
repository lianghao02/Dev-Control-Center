[CmdletBinding()]
param([string]$DevelopmentRoot = '', [switch]$Force, [switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path $PSScriptRoot 'scripts\lib\bootstrap.ps1')
if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) { $DevelopmentRoot = Get-HomeDevelopmentRoot $PSScriptRoot }
$root = [IO.Path]::GetFullPath($DevelopmentRoot)
$hostExe = Get-HomePowerShell
$projects = @('01_AG-MONITOR-Smart-Video-Screening','07_auto-learning-bot','10_Smart-Photo-Organizer','12_ClipMask-AI','14_Google-Photos-Takeout-Organizer','15_chainflow-inspector')
$failed = @()
foreach ($name in $projects) {
    $projectDir = Join-Path $root $name
    $setup = Join-Path $projectDir 'setup_and_run.ps1'
    try {
        if ($name -eq '14_Google-Photos-Takeout-Organizer') {
            # 已有完整環境，只驗證；不納入批次重建。
            $pythonExe = Join-Path $projectDir '.venv\Scripts\python.exe'
            & $pythonExe -B -s -c 'import sys,site,PySide6,PIL,pillow_heif; assert sys.version_info[:2] == (3,13); assert sys.prefix != sys.base_prefix; assert not site.ENABLE_USER_SITE'
            if ($LASTEXITCODE -ne 0) { throw '既有 .venv 驗證失敗' }
            & $pythonExe -B -s -m pip --disable-pip-version-check check
        } else {
            $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',$setup)
            if ($CheckOnly) { $arguments += '-CheckOnly' } else { $arguments += '-NoLaunch' }
            if ($Force -and -not $CheckOnly -and $name -in @('10_Smart-Photo-Organizer','12_ClipMask-AI','15_chainflow-inspector')) { $arguments += '-Force' }
            & $hostExe @arguments
        }
        if ($LASTEXITCODE -ne 0) { throw "結束碼：$LASTEXITCODE" }
        Write-Host "就緒：$name"
    } catch {
        $failed += $name
        Write-Warning "$name：$($_.Exception.Message)"
    }
}
if ($failed.Count) { throw "環境檢查未通過：$($failed -join ', ')" }
Write-Host '六個現行 Python 專案環境檢查完成。'
