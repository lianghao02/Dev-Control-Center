[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$BinaryDir)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$center = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$binary = (Resolve-Path -LiteralPath $BinaryDir).Path
if (Get-Process -Name WINWORD,EXCEL,POWERPNT -ErrorAction SilentlyContinue) { throw 'Office 正在執行，停止驗收以保護使用者文件。' }
$session = Join-Path $center ('artifacts/new-build-acceptance-20261006/中文 Office 驗收-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $session -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $session '.office-acceptance'), '純合成驗收', [Text.UTF8Encoding]::new($false))
& dotnet build (Join-Path $PSScriptRoot 'office_acceptance/OfficeAcceptance.csproj') -c Release --nologo -v quiet "-p:BinaryDir=$binary" "-p:OutputPath=$session"
if ($LASTEXITCODE -ne 0) { throw 'Office 驗收建置失敗。' }
Get-ChildItem -LiteralPath $binary -File -Filter '*.dll' | Copy-Item -Destination $session -Force
$run = Start-Process -FilePath (Join-Path $session 'OfficeAcceptance.exe') -ArgumentList ('"' + $session + '"') -WorkingDirectory $session -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $session 'result.txt') -RedirectStandardError (Join-Path $session 'error.txt')
$null = $run.Handle
if (-not $run.WaitForExit(90000)) {
    $run.Kill()
    $run.WaitForExit()
    throw "Office 隔離驗收逾時；先檢查 COM 程序與 $session 證據，不強制關閉其他 Office。"
}
Get-Content -LiteralPath (Join-Path $session 'result.txt') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $session 'error.txt') -Encoding UTF8
if ($run.ExitCode -ne 0) { throw "Office 驗收失敗，退出碼 $($run.ExitCode)：$session" }
Get-Content -LiteralPath (Join-Path $session 'verification.json') -Encoding UTF8
Write-Output "Office 驗收完成：$session；若 BlockedOfficePdfs 大於 0，正常 Office 轉檔仍未通過。"
