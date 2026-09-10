# UTF-8 Compatibility
[CmdletBinding()]
param(
    [ValidateSet('Menu', 'QuickScan', 'SafeSync', 'Build', 'AgentCheck', 'AgentSync', 'Environment', 'Gui')]
    [string]$Action = 'Menu'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'lib\bootstrap.ps1')

$homeRepo = Split-Path -Parent $PSScriptRoot
$powerShellHost = Get-HomePowerShell

function Invoke-DevHubScript {
    param(
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string[]]$Arguments = @()
    )

    if (-not (Test-Path -LiteralPath $ScriptPath -PathType Leaf)) {
        throw "找不到控制中心腳本：$ScriptPath"
    }

    & $powerShellHost -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "控制中心作業失敗，結束代碼：$LASTEXITCODE"
    }
}

function Invoke-DevHubAction {
    param([Parameter(Mandatory = $true)][string]$SelectedAction)

    switch ($SelectedAction) {
        'QuickScan' {
            Invoke-DevHubScript (Join-Path $PSScriptRoot 'workspace_sync_hub.ps1') @('-Action', 'QuickScan')
        }
        'SafeSync' {
            Invoke-DevHubScript (Join-Path $PSScriptRoot 'workspace_sync_hub.ps1') @('-Action', 'Auto')
        }
        'Build' {
            Invoke-DevHubScript (Join-Path $homeRepo 'build_all_desktop_apps.ps1') @('-Execute')
        }
        'AgentCheck' {
            Invoke-DevHubScript (Join-Path $PSScriptRoot 'sync_codex.ps1') @('-CheckOnly')
        }
        'AgentSync' {
            Invoke-DevHubScript (Join-Path $PSScriptRoot 'sync_codex.ps1') @('-Execute')
        }
        'Environment' {
            Invoke-DevHubScript (Join-Path $PSScriptRoot 'setup_environment_hub.ps1')
        }
        'Gui' {
            $guiScript = Join-Path $PSScriptRoot 'gui.ps1'
            if (-not (Test-Path -LiteralPath $guiScript -PathType Leaf)) {
                throw "找不到 GUI 腳本：$guiScript"
            }
            Start-Process -FilePath $powerShellHost -ArgumentList @('-STA', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $guiScript) | Out-Null
            Write-Host '已開啟 GUI 儀表板；GUI 預設不會自動掃描。' -ForegroundColor Green
        }
        default { throw "不支援的操作：$SelectedAction" }
    }
}

function Show-DevHubMenu {
    # 非互動式主控台（例如自動化驗證或輸出重新導向）可能不支援清畫面；
    # 清畫面只是視覺效果，絕不可阻斷選單本身。
    try { Clear-Host } catch {}
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' LiangHao Dev Control Center' -ForegroundColor Cyan
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '[1] 快速檢查所有專案'
    Write-Host '[2] 安全同步所有專案（缺少時 Clone）'
    Write-Host '[3] 建置桌面應用程式'
    Write-Host '[4] 檢查 / 同步 Agent 設定'
    Write-Host '[5] 開發環境檢查'
    Write-Host '[6] 開啟 GUI 儀表板'
    Write-Host '[Q] 離開'
    Write-Host ''
    Write-Host '=========================================' -ForegroundColor Cyan
}

if ($Action -ne 'Menu') {
    Invoke-DevHubAction -SelectedAction $Action
    exit 0
}

while ($true) {
    Show-DevHubMenu
    $choice = (Read-Host '請輸入選項 (1-6 或 Q)').Trim().ToUpperInvariant()
    if ($choice -eq 'Q') { break }

    try {
        switch ($choice) {
            '1' { Invoke-DevHubAction -SelectedAction 'QuickScan' }
            '2' { Invoke-DevHubAction -SelectedAction 'SafeSync' }
            '3' { Invoke-DevHubAction -SelectedAction 'Build' }
            '4' {
                $agentChoice = (Read-Host '輸入 1 僅檢查，輸入 2 正式同步，其他鍵取消').Trim()
                if ($agentChoice -eq '1') { Invoke-DevHubAction -SelectedAction 'AgentCheck' }
                elseif ($agentChoice -eq '2') { Invoke-DevHubAction -SelectedAction 'AgentSync' }
                else { Write-Host '已取消 Agent 作業。' -ForegroundColor Gray }
            }
            '5' { Invoke-DevHubAction -SelectedAction 'Environment' }
            '6' { Invoke-DevHubAction -SelectedAction 'Gui' }
            default { Write-Host '無效選項，未執行任何作業。' -ForegroundColor Yellow }
        }
    } catch {
        Write-Host "作業失敗：$($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ''
    [void](Read-Host '按 Enter 返回主選單')
}
