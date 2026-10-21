# UTF-8 Compatibility
[CmdletBinding()]
param(
    [ValidateSet('Menu', 'QuickScan', 'SafeSync', 'Build', 'AgentCheck', 'AgentSync', 'Environment')]
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
        default { throw "不支援的操作：$SelectedAction" }
    }
}

function Show-DevHubMenu {
    # 非互動式主控台（例如自動化驗證或輸出重新導向）可能不支援清畫面；
    # 清畫面只是視覺效果，絕不可阻斷選單本身。
    try { Clear-Host } catch {}
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ' LiangHao 開發中樞' -ForegroundColor Cyan
    Write-Host '=========================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '[1] 看看哪些專案有改過、還沒上傳'
    Write-Host '    只查看，不會動到任何檔案' -ForegroundColor DarkGray
    Write-Host '[2] 跟 GitHub 對齊所有專案'
    Write-Host '    補下載缺少的專案、拉下 GitHub 上的新進度、上傳已 commit 的內容' -ForegroundColor DarkGray
    Write-Host '    還沒 commit 的修改不會被動到，該專案會直接跳過' -ForegroundColor DarkGray
    Write-Host '[3] 重新打包所有桌面程式（exe／zip）'
    Write-Host '    會直接開始編譯，需要幾分鐘；不會發布到 GitHub' -ForegroundColor DarkGray
    Write-Host '[4] 更新 AI 助手的規則與技能（Codex／Antigravity／Claude）'
    Write-Host '    改過 configs 資料夾後使用；可先只比對差異' -ForegroundColor DarkGray
    Write-Host '[5] 檢查電腦上的開發工具是否齊全'
    Write-Host '    Git、.NET、Python 等' -ForegroundColor DarkGray
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
    $choice = (Read-Host '請輸入數字 1～5，或 Q 離開').Trim().ToUpperInvariant()
    if ($choice -eq 'Q') { break }

    try {
        switch ($choice) {
            '1' { Invoke-DevHubAction -SelectedAction 'QuickScan' }
            '2' { Invoke-DevHubAction -SelectedAction 'SafeSync' }
            '3' { Invoke-DevHubAction -SelectedAction 'Build' }
            '4' {
                Write-Host '  1 = 只比對差異，不寫入'
                Write-Host '  2 = 正式更新到 Codex、Antigravity 與 Claude'
                $agentChoice = (Read-Host '請輸入 1 或 2（其他鍵取消）').Trim()
                if ($agentChoice -eq '1') { Invoke-DevHubAction -SelectedAction 'AgentCheck' }
                elseif ($agentChoice -eq '2') { Invoke-DevHubAction -SelectedAction 'AgentSync' }
                else { Write-Host '已取消，沒有做任何變更。' -ForegroundColor Gray }
            }
            '5' { Invoke-DevHubAction -SelectedAction 'Environment' }
            default { Write-Host '沒有這個選項，什麼都沒做。' -ForegroundColor Yellow }
        }
    } catch {
        Write-Host "執行失敗：$($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ''
    [void](Read-Host '按 Enter 回到選單')
}
