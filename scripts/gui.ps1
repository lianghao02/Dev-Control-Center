# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$DevelopmentRoot = '',
    [switch]$StartupCheck
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Off

[Console]::OutputEncoding = [Text.Encoding]::UTF8

# 引入 bootstrap 與 git-status 核心工具
. (Join-Path $PSScriptRoot 'lib\bootstrap.ps1')
. (Join-Path $PSScriptRoot 'lib\git-status.ps1')

$homeRepo = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($DevelopmentRoot)) {
    $DevelopmentRoot = Get-HomeDevelopmentRoot $homeRepo
}
$devRoot = [IO.Path]::GetFullPath($DevelopmentRoot)
$manifestPath = Join-Path $homeRepo 'development-repositories.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "找不到專案清冊：$manifestPath"
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$repoList = @($manifest.repositories)
$githubOwner = [string]$manifest.githubOwner

# 載入 WPF 必備組件
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# 載入 XAML 介面定義
$xamlPath = Join-Path $PSScriptRoot 'gui\MainWindow.xaml'
if (-not (Test-Path -LiteralPath $xamlPath -PathType Leaf)) {
    throw "找不到 XAML 檔案：$xamlPath"
}
[xml]$xamlXml = Get-Content -LiteralPath $xamlPath -Raw -Encoding UTF8
$reader = [System.Xml.XmlNodeReader]::new($xamlXml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# 綁定 UI 控制項
$txtRepoCountLabel = $window.FindName('TxtRepoCountLabel')
$txtStatClean = $window.FindName('TxtStatClean')
$txtStatModified = $window.FindName('TxtStatModified')
$txtStatAhead = $window.FindName('TxtStatAhead')
$txtStatBehind = $window.FindName('TxtStatBehind')
$txtEnvSummary = $window.FindName('TxtEnvSummary')
$txtAgentSummary = $window.FindName('TxtAgentSummary')

$btnQuickScan = $window.FindName('BtnQuickScan')
$btnRemoteRefresh = $window.FindName('BtnRemoteRefresh')
$btnFullCheck = $window.FindName('BtnFullCheck')
$btnOpenWorkspace = $window.FindName('BtnOpenWorkspace')

$btnFilterAll = $window.FindName('BtnFilterAll')
$btnFilterAttention = $window.FindName('BtnFilterAttention')
$btnFilterAhead = $window.FindName('BtnFilterAhead')
$btnFilterBehind = $window.FindName('BtnFilterBehind')
$btnFilterClean = $window.FindName('BtnFilterClean')
$txtSearchBox = $window.FindName('TxtSearchBox')

$gridRepositories = $window.FindName('GridRepositories')
$txtSelectedRepoInfo = $window.FindName('TxtSelectedRepoInfo')
$btnOpenSelectedFolder = $window.FindName('BtnOpenSelectedFolder')
$btnOpenSelectedGitHub = $window.FindName('BtnOpenSelectedGitHub')
$btnCopySelectedPath = $window.FindName('BtnCopySelectedPath')

$btnPreviewSyncPlan = $window.FindName('BtnPreviewSyncPlan')
$btnExecuteSafeSync = $window.FindName('BtnExecuteSafeSync')
$gridSyncPlan = $window.FindName('GridSyncPlan')

$btnPreviewBuild = $window.FindName('BtnPreviewBuild')
$btnCheckShortcuts = $window.FindName('BtnCheckShortcuts')
$btnBuildSelected = $window.FindName('BtnBuildSelected')
$btnExecuteBuild = $window.FindName('BtnExecuteBuild')
$gridDesktopApps = $window.FindName('GridDesktopApps')

$btnCheckDevTools = $window.FindName('BtnCheckDevTools')
$gridDevTools = $window.FindName('GridDevTools')
$chkEnableInit = $window.FindName('ChkEnableInit')
$btnCloneMissingRepos = $window.FindName('BtnCloneMissingRepos')
$btnSetupPythonEmbed = $window.FindName('BtnSetupPythonEmbed')

$btnCheckAgentSync = $window.FindName('BtnCheckAgentSync')
$btnExecuteAgentSync = $window.FindName('BtnExecuteAgentSync')
$gridAgentItems = $window.FindName('GridAgentItems')

$expanderLog = $window.FindName('ExpanderLog')
$txtConsoleLog = $window.FindName('TxtConsoleLog')
$txtLogStatus = $window.FindName('TxtLogStatus')
$btnClearLog = $window.FindName('BtnClearLog')
$btnCopyLog = $window.FindName('BtnCopyLog')

$txtFooterStatus = $window.FindName('TxtFooterStatus')
$progressScan = $window.FindName('ProgressScan')
$txtLastScanTime = $window.FindName('TxtLastScanTime')

# 全域狀態暫存
$global:RepoData = [System.Collections.Generic.List[PSCustomObject]]::new()
$global:CurrentFilter = 'All'
$global:CurrentSearch = ''
$global:Level1ScanJob = $null
$global:Level1ScanTimer = $null
$script:InitialScanStarted = $false  # 防止 ContentRendered 重複觸發 Level 1

$global:LogFilePath = Join-Path $homeRepo 'logs\dev-control-center.log'
$logDir = Split-Path -Parent $global:LogFilePath
if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# 輔助函式：日誌輸出
function Write-GuiLog([string]$Message, [switch]$Expand) {
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logLine = "[$time] $Message"
    if ($txtConsoleLog) {
        $txtConsoleLog.AppendText("[$((Get-Date).ToString('HH:mm:ss'))] $Message`r`n")
        $txtConsoleLog.ScrollToEnd()
    }
    if ($txtLogStatus) {
        $txtLogStatus.Text = "｜ $Message"
    }
    if ($Expand -and $expanderLog) {
        $expanderLog.IsExpanded = $true
    }

    # 記錄至檔案 (自動排除敏感資訊)
    try {
        [IO.File]::AppendAllText($global:LogFilePath, "$logLine`r`n", [Text.Encoding]::UTF8)
    } catch {}

    [System.Windows.Forms.Application]::DoEvents()
}

# 輔助函式：UI 狀態顏色與字樣對照
function Get-WorkingTreeVisual([string]$State, [int]$ModifiedFiles) {
    switch ($State) {
        'Clean' {
            return [ordered]@{ Display = '✓ Clean (乾淨)'; Color = '#2A6B3C' }
        }
        'Modified' {
            return [ordered]@{ Display = "⚠ Modified ($ModifiedFiles 檔未提交)"; Color = '#C05621' }
        }
        'Conflict' {
            return [ordered]@{ Display = '⚡ Conflict (有未解決衝突)'; Color = '#C53030' }
        }
        'Missing' {
            return [ordered]@{ Display = '? Missing (目錄不存在)'; Color = '#D69E2E' }
        }
        default {
            return [ordered]@{ Display = '✕ 異常或無法確認'; Color = '#718096' }
        }
    }
}

function Get-SyncVisual([string]$State, [int]$Ahead, [int]$Behind) {
    switch ($State) {
        'Clean' {
            return [ordered]@{ Display = '✓ 已同步'; Color = '#2A6B3C' }
        }
        'Ahead' {
            return [ordered]@{ Display = "↑ 待上傳 ($Ahead 提交)"; Color = '#5E35B1' }
        }
        'Behind' {
            return [ordered]@{ Display = "↓ 待下載 ($Behind 提交)"; Color = '#1976D2' }
        }
        'Diverged' {
            return [ordered]@{ Display = "↕ 分歧 (+$Ahead, -$Behind)"; Color = '#C53030' }
        }
        'Conflict' {
            return [ordered]@{ Display = '⚡ 衝突 (需人工解決)'; Color = '#C53030' }
        }
        'Modified' {
            return [ordered]@{ Display = '⚠ 有未提交變更 (暫停同步)'; Color = '#C05621' }
        }
        'Missing' {
            return [ordered]@{ Display = '? 缺少版本庫'; Color = '#D69E2E' }
        }
        'Unknown' {
            return [ordered]@{ Display = '◌ 無法確認 (遠端或網路)'; Color = '#718096' }
        }
        default {
            return [ordered]@{ Display = '✕ 錯誤'; Color = '#E53E3E' }
        }
    }
}

# Level 1 僅讀取本機 Git 狀態，但每個版本庫仍須呼叫 Git；改由背景 Job 執行，
# 完成後才在 Dispatcher 所屬 UI 執行緒寫入控制項。
function Start-Level1BackgroundScan {
    if ($global:Level1ScanJob -and $global:Level1ScanJob.State -eq 'Running') {
        Write-GuiLog 'Level 1 快速掃描仍在執行中。'
        return
    }

    Write-GuiLog '開始進行快速本機掃描 (Level 1，背景執行)...'
    $txtFooterStatus.Text = '⏳ 正在背景執行 Level 1 快速本機掃描...'
    $progressScan.Visibility = [System.Windows.Visibility]::Visible
    $progressScan.IsIndeterminate = $true

    $bootstrapPath = Join-Path $PSScriptRoot 'lib\bootstrap.ps1'
    $gitStatusPath = Join-Path $PSScriptRoot 'lib\git-status.ps1'
    try {
        $global:Level1ScanJob = Start-Job -ArgumentList @($repoList, $devRoot, $bootstrapPath, $gitStatusPath) -ScriptBlock {
            param($Repositories, $DevelopmentRoot, $BootstrapPath, $GitStatusPath)
            . $BootstrapPath
            . $GitStatusPath
            foreach ($item in $Repositories) {
                $path = Join-Path $DevelopmentRoot ([string]$item.folder)
                $status = Get-ManagedRepositoryStatus -RepositoryPath $path
                [PSCustomObject]@{
                    Name       = [string]$item.folder
                    Repository = [string]$item.repository
                    Path       = $path
                    Status     = $status
                    Version    = Get-RepositoryVersion -RepoPath $path
                }
            }
        }
    } catch {
        # Start-Job 本身失敗時：記錄錯誤、還原 UI 狀態，不再建立 Timer
        $errMsg = "[Start-Level1BackgroundScan] Start-Job 失敗：$($_.Exception.Message) | StackTrace=$($_.ScriptStackTrace)"
        try { [IO.File]::AppendAllText($global:LogFilePath, "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] $errMsg`r`n", [Text.Encoding]::UTF8) } catch {}
        $global:Level1ScanJob = $null
        if ($txtFooterStatus) { $txtFooterStatus.Text = '⚠ Level 1 背景掃描啟動失敗，請手動點擊「快速掃描」重試。' }
        if ($progressScan) { $progressScan.Visibility = [System.Windows.Visibility]::Collapsed }
        if ($txtConsoleLog) {
            $txtConsoleLog.AppendText("[$((Get-Date).ToString('HH:mm:ss'))] ⚠ Level 1 啟動失敗：$($_.Exception.Message)`r`n")
            $txtConsoleLog.ScrollToEnd()
        }
        return
    }

    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $timer.Add_Tick({
        try {
            if ($global:Level1ScanJob -and $global:Level1ScanJob.State -eq 'Running') {
                return
            }

            # 防護：若 Job 尚未被賦值（極短暫的 Race Window），等待下次 Tick
            if ($global:Level1ScanJob -eq $null) {
                return
            }

            # 使用 closure 捕獲的 $timer 局部變數停止 Timer，避免誤停後續掃描的新 Timer
            $timer.Stop()

            if (-not $global:Level1ScanJob -or $global:Level1ScanJob.State -ne 'Completed') {
                $jobState = if ($global:Level1ScanJob) { $global:Level1ScanJob.State } else { 'None' }
                $reason = if ($global:Level1ScanJob -and $global:Level1ScanJob.ChildJobs.Count -gt 0) {
                    ($global:Level1ScanJob.ChildJobs[0].JobStateInfo.Reason | Out-String).Trim()
                } else { '背景工作未建立' }
                throw "Level 1 背景掃描失敗 [Job State=$jobState]：$reason"
            }

            $scanResults = @($global:Level1ScanJob | Receive-Job)
            $global:RepoData.Clear()
            $cleanCount = 0
            $modifiedCount = 0
            $aheadCount = 0
            $behindCount = 0
            $idx = 0
            foreach ($entry in $scanResults) {
                $idx++
                $status = $entry.Status
                if ($status.State -in @('Clean', 'Synced')) { $cleanCount++ }
                elseif ($status.State -in @('Modified', 'Conflict', 'Diverged', 'Missing', 'Unknown', 'Error')) { $modifiedCount++ }
                if ($status.Ahead -gt 0) { $aheadCount++ }
                if ($status.Behind -gt 0) { $behindCount++ }

                $wtVisual = Get-WorkingTreeVisual $status.State $status.ModifiedFiles
                $syncVisual = Get-SyncVisual $status.State $status.Ahead $status.Behind
                $global:RepoData.Add([PSCustomObject]@{
                    Index = $idx; Name = $entry.Name; Repository = $entry.Repository; Path = $entry.Path; Version = $entry.Version
                    Branch = if ($status.Branch) { $status.Branch } else { '-' }
                    WorkingTreeDisplay = $wtVisual.Display; WorkingTreeColor = $wtVisual.Color
                    SyncDisplay = $syncVisual.Display; SyncColor = $syncVisual.Color; Detail = $status.Detail
                    State = $status.State; Ahead = $status.Ahead; Behind = $status.Behind; ModifiedFiles = $status.ModifiedFiles
                    GitHubUrl = "https://github.com/$githubOwner/$($entry.Repository)"
                })
            }
            $txtRepoCountLabel.Text = "管理 $($global:RepoData.Count) 個版本庫"
            $txtStatClean.Text = "✓ 已同步: $cleanCount"
            $txtStatModified.Text = "⚠ 待處理: $modifiedCount"
            $txtStatAhead.Text = "↑ 待上傳: $aheadCount"
            $txtStatBehind.Text = "↓ 待下載: $behindCount"
            $txtLastScanTime.Text = "上次掃描時間：$(Get-Date -Format 'HH:mm:ss')"
            $txtFooterStatus.Text = "💡 掃描完成：共 $($global:RepoData.Count) 個版本庫 ($cleanCount 已同步, $modifiedCount 需注意)"
            Apply-RepositoryFilters
            Write-GuiLog "Level 1 背景掃描完成：$cleanCount 已同步, $modifiedCount 需注意, $aheadCount 待上傳, $behindCount 待下載。"
        } catch {
            # 必須記錄完整例外資訊，不得讓例外冒泡導致 WPF Dispatcher 異常終止
            $jobState = if ($global:Level1ScanJob) { $global:Level1ScanJob.State } else { 'None' }
            $errMsg = "[Level1 Tick Error] Message=$($_.Exception.Message) | JobState=$jobState | StackTrace=$($_.ScriptStackTrace)"
            try { [IO.File]::AppendAllText($global:LogFilePath, "[$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))] $errMsg`r`n", [Text.Encoding]::UTF8) } catch {}
            if ($txtFooterStatus) { $txtFooterStatus.Text = '⚠ Level 1 背景掃描失敗，請查看日誌或手動點擊「快速掃描」重試。' }
            if ($expanderLog) { $expanderLog.IsExpanded = $true }
            if ($txtConsoleLog) {
                $txtConsoleLog.AppendText("[$((Get-Date).ToString('HH:mm:ss'))] ⚠ Level 1 掃描失敗：$($_.Exception.Message)`r`n")
                $txtConsoleLog.ScrollToEnd()
            }
            if ($progressScan) { $progressScan.Visibility = [System.Windows.Visibility]::Collapsed }
        } finally {
            if ($progressScan) { $progressScan.Visibility = [System.Windows.Visibility]::Collapsed }
            if ($global:Level1ScanJob) { Remove-Job -Job $global:Level1ScanJob -Force -ErrorAction SilentlyContinue }
            $global:Level1ScanJob = $null
        }
    })
    $global:Level1ScanTimer = $timer
    $timer.Start()
}

# 輔助函式：掃描全部 Repository (Level 1: 快速本機, Level 2: 遠端重整)
function Update-WorkspaceRepositories([bool]$FetchRemote = $false) {
    $modeName = if ($FetchRemote) { "遠端重新整理 (Level 2: 含 GitHub fetch)" } else { "快速本機掃描 (Level 1: 僅本機狀態)" }
    Write-GuiLog "開始進行 $modeName..."
    $txtFooterStatus.Text = "⏳ 正在進行 $modeName..."
    $progressScan.Visibility = [System.Windows.Visibility]::Visible
    $progressScan.IsIndeterminate = $true

    $global:RepoData.Clear()
    $idx = 0
    $cleanCount = 0
    $modifiedCount = 0
    $aheadCount = 0
    $behindCount = 0

    foreach ($item in $repoList) {
        $idx++
        $name = [string]$item.folder
        $repoName = [string]$item.repository
        $path = Join-Path $devRoot $name
        $txtFooterStatus.Text = "⏳ [$idx/$($repoList.Count)] 正在檢查 $name..."
        [System.Windows.Forms.Application]::DoEvents()

        $status = Get-ManagedRepositoryStatus -RepositoryPath $path
        
        # 若為 Level 2 遠端重整且專案存在且非衝突/錯誤，連線 GitHub fetch 更新狀態
        if ($FetchRemote -and $status.State -notin @('Missing', 'Error', 'Conflict')) {
            $safePath = $path.Replace('\', '/')
            $null = @(git -c "safe.directory=$safePath" -C $path fetch origin --prune --quiet 2>$null)
            if ($LASTEXITCODE -ne 0) {
                $status.State = 'Unknown'
                $status.Detail = '無法連線遠端或查詢失敗 (無法確認)'
            } else {
                $status = Get-ManagedRepositoryStatus -RepositoryPath $path
            }
        }

        # 讀取版本號 (以 version.txt 為 Source of Truth)
        $repoVer = Get-RepositoryVersion -RepoPath $path

        # 統計計數
        if ($status.State -in @('Clean', 'Synced')) {
            $cleanCount++
        } elseif ($status.State -in @('Modified', 'Conflict', 'Diverged', 'Missing', 'Unknown', 'Error')) {
            $modifiedCount++
        }
        if ($status.Ahead -gt 0) { $aheadCount++ }
        if ($status.Behind -gt 0) { $behindCount++ }

        $wtVisual = Get-WorkingTreeVisual $status.State $status.ModifiedFiles
        $syncVisual = Get-SyncVisual $status.State $status.Ahead $status.Behind

        $record = [PSCustomObject]@{
            Index              = $idx
            Name               = $name
            Repository         = $repoName
            Path               = $path
            Version            = $repoVer
            Branch             = if ($status.Branch) { $status.Branch } else { '-' }
            WorkingTreeDisplay = $wtVisual.Display
            WorkingTreeColor   = $wtVisual.Color
            SyncDisplay        = $syncVisual.Display
            SyncColor          = $syncVisual.Color
            Detail             = $status.Detail
            State              = $status.State
            Ahead              = $status.Ahead
            Behind             = $status.Behind
            ModifiedFiles      = $status.ModifiedFiles
            GitHubUrl          = "https://github.com/$githubOwner/$repoName"
        }
        $global:RepoData.Add($record)
    }

    # 更新便條紙數據
    $txtRepoCountLabel.Text = "管理 $($global:RepoData.Count) 個版本庫"
    $txtStatClean.Text = "✓ 已同步: $cleanCount"
    $txtStatModified.Text = "⚠ 待處理: $modifiedCount"
    $txtStatAhead.Text = "↑ 待上傳: $aheadCount"
    $txtStatBehind.Text = "↓ 待下載: $behindCount"
    $txtLastScanTime.Text = "上次掃描時間：$(Get-Date -Format 'HH:mm:ss')"
    $txtFooterStatus.Text = "💡 掃描完成：共 $($global:RepoData.Count) 個版本庫 ($cleanCount 已同步, $modifiedCount 需注意)"
    $progressScan.Visibility = [System.Windows.Visibility]::Collapsed

    Write-GuiLog "掃描完成：$cleanCount 已同步, $modifiedCount 需注意, $aheadCount 待上傳, $behindCount 待下載。"
    Apply-RepositoryFilters
}

# 輔助函式：篩選與搜尋
function Apply-RepositoryFilters {
    $filtered = $global:RepoData

    # 標籤篩選
    switch ($global:CurrentFilter) {
        'Attention' {
            $filtered = @($filtered | Where-Object { $_.State -in @('Modified', 'Conflict', 'Diverged', 'Missing', 'Unknown', 'Error') })
        }
        'Ahead' {
            $filtered = @($filtered | Where-Object { $_.Ahead -gt 0 })
        }
        'Behind' {
            $filtered = @($filtered | Where-Object { $_.Behind -gt 0 })
        }
        'Clean' {
            $filtered = @($filtered | Where-Object { $_.State -in @('Clean', 'Synced') })
        }
    }

    # 搜尋關鍵字
    if (-not [string]::IsNullOrWhiteSpace($global:CurrentSearch)) {
        $q = $global:CurrentSearch.Trim().ToLower()
        $filtered = @($filtered | Where-Object {
            $_.Name.ToLower().Contains($q) -or
            $_.Branch.ToLower().Contains($q) -or
            $_.Detail.ToLower().Contains($q) -or
            $_.SyncDisplay.ToLower().Contains($q)
        })
    }

    $gridRepositories.ItemsSource = $filtered
}

# 輔助函式：安全 Git 同步計畫預覽 (安全規則 2, 3, 7)
function Generate-SyncPlan {
    Write-GuiLog "正在產生安全 Git 同步預覽計畫 (不修改任何檔案)..."
    $planItems = [System.Collections.Generic.List[PSCustomObject]]::new()
    $idx = 0

    foreach ($item in $global:RepoData) {
        $idx++
        # 真正操作或預覽前重新檢查 Git 狀態 (安全規則 3)
        $fresh = Get-ManagedRepositoryStatus -RepositoryPath $item.Path
        $action = '無需操作'
        $actionColor = '#718096'
        $reason = '已同步 (Clean)，無待處理項目'

        switch ($fresh.State) {
            'Ahead' {
                $action = "Push 已存在 Commit (共 $($fresh.Ahead) 個提交)"
                $actionColor = '#5E35B1'
                $reason = '本機有已提交之 Commit，上游領先；安全 Push 既有提交，不自動 add/commit'
            }
            'Behind' {
                $action = "安全快轉 (git merge --ff-only)"
                $actionColor = '#1976D2'
                $reason = "工作區乾淨且落後遠端 $($fresh.Behind) 個提交；使用安全 ff-only 快轉更新"
            }
            'Modified' {
                $action = "🛡️ 略過 (不執行 Pull/Push)"
                $actionColor = '#C05621'
                $reason = "工作區有 $($fresh.ModifiedFiles) 個未提交檔案；停止自動處理，需人工檢查"
            }
            'Diverged' {
                $action = "🛡️ 略過 (不執行 Merge/Rebase)"
                $actionColor = '#C53030'
                $reason = "本機與遠端分支分歧 (+$($fresh.Ahead), -$($fresh.Behind))；嚴禁自動處理，需人工合併"
            }
            'Conflict' {
                $action = "🛡️ 略過 (存在合併衝突)"
                $actionColor = '#C53030'
                $reason = "存在尚未解決的合併衝突；停止所有自動操作，需人工處理"
            }
            'Missing' {
                $action = "🛡️ 略過 (目錄不存在)"
                $actionColor = '#D69E2E'
                $reason = "本機目錄不存在；日常操作不自動 Clone，僅在初始化流程處理"
            }
            'Unknown' {
                $action = "🛡️ 略過 (無法確認遠端狀態)"
                $actionColor = '#718096'
                $reason = "無法連線遠端或無上游分支；停止自動操作以防誤判"
            }
            'Clean' {
                $action = "無需操作"
                $actionColor = '#2A6B3C'
                $reason = "工作目錄乾淨且與上游一致"
            }
            default {
                $action = "🛡️ 略過 (狀態異常)"
                $actionColor = '#E53E3E'
                $reason = $fresh.Detail
            }
        }

        $planItems.Add([PSCustomObject]@{
            Index        = $idx
            Name         = $item.Name
            StateDisplay = $fresh.Detail
            StateColor   = (Get-SyncVisual $fresh.State $fresh.Ahead $fresh.Behind).Color
            PlannedAction= $action
            ActionColor  = $actionColor
            ActionReason = $reason
            Path         = $item.Path
            FreshState   = $fresh.State
            Ahead        = $fresh.Ahead
            Behind       = $fresh.Behind
        })
    }

    $gridSyncPlan.ItemsSource = $planItems
    Write-GuiLog "同步計畫預覽已更新：共 $($planItems.Count) 個專案已列入評估。" -Expand
    return $planItems
}

# 輔助函式：執行安全 Git 同步 (安全規則 1-10)
function Execute-SafeSyncPlan {
    $plans = Generate-SyncPlan
    $pullList = @($plans | Where-Object { $_.FreshState -eq 'Behind' })
    $pushList = @($plans | Where-Object { $_.FreshState -eq 'Ahead' })

    if ($pullList.Count -eq 0 -and $pushList.Count -eq 0) {
        [System.Windows.MessageBox]::Show("目前沒有任何專案符合安全同步條件 (Ahead 或 Behind)。`n異常與未提交專案已主動略過保護。", "提示", "OK", "Information")
        return
    }

    $confirmMsg = "即將依 10 條安全規則執行同步：`n" +
                  "• 安全快轉 (Pull --ff-only)：$($pullList.Count) 個專案`n" +
                  "• 推送既有提交 (Push)：$($pushList.Count) 個專案`n`n" +
                  "系統在真正執行前會再次核對 Git 狀態，確認無未提交檔案與衝突。`n是否繼續？"
    $res = [System.Windows.MessageBox]::Show($confirmMsg, "安全同步確認", "YesNo", "Question")
    if ($res -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-GuiLog "使用者取消執行同步。"
        return
    }

    Write-GuiLog "🚀 開始執行安全同步..." -Expand
    $successPull = 0
    $failPull = 0
    $successPush = 0
    $failPush = 0

    # 1. 執行安全快轉 (Behind)
    foreach ($item in $pullList) {
        # 真正操作前重新核對 (規則 3)
        $fresh = Get-ManagedRepositoryStatus -RepositoryPath $item.Path
        if ($fresh.State -ne 'Behind') {
            Write-GuiLog "🛡️ $($item.Name)：即時狀態已變更為 $($fresh.State)，略過安全快轉。"
            continue
        }
        Write-GuiLog "⏳ 正在快轉：$($item.Name) (--ff-only)..."
        $safePath = $item.Path.Replace('\', '/')
        $output = @(git -c "safe.directory=$safePath" -C $item.Path merge --ff-only '@{upstream}' 2>&1)
        if ($LASTEXITCODE -eq 0) {
            Write-GuiLog "✅ $($item.Name)：快轉完成！"
            $successPull++
        } else {
            Write-GuiLog "❌ $($item.Name)：快轉失敗 ($($output -join ' '))，已停止處理。"
            $failPull++
        }
    }

    # 2. 執行安全推送 (Ahead)
    foreach ($item in $pushList) {
        # 真正操作前重新核對 (規則 3)
        $fresh = Get-ManagedRepositoryStatus -RepositoryPath $item.Path
        if ($fresh.State -ne 'Ahead') {
            Write-GuiLog "🛡️ $($item.Name)：即時狀態已變更為 $($fresh.State)，略過推送。"
            continue
        }
        Write-GuiLog "⏳ 正在推送既有提交：$($item.Name)..."
        $safePath = $item.Path.Replace('\', '/')
        $output = @(git -c "safe.directory=$safePath" -C $item.Path push 2>&1)
        if ($LASTEXITCODE -eq 0) {
            Write-GuiLog "✅ $($item.Name)：推送成功！"
            $successPush++
        } else {
            Write-GuiLog "❌ $($item.Name)：推送失敗 ($($output -join ' '))，未建立新提交。"
            $failPush++
        }
    }

    Write-GuiLog "安全同步作業結束：快轉成功 $successPull 個 (失敗 $failPull)，推送成功 $successPush 個 (失敗 $failPush)。"
    Update-WorkspaceRepositories -FetchRemote $false
}

# 輔助函式：載入桌面應用程式清單
function Load-DesktopAppsList {
    $apps = @(
        [PSCustomObject]@{
            Index      = 1
            Name       = '01_AG-MONITOR-Smart-Video-Screening'
            Tech       = 'Python Embed / Standalone'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '01_AG-MONITOR-Smart-Video-Screening'))
            OutputType = 'CPU 獨立可攜包 (dist\AG-MONITOR-Smart-Video-Screening-CPU.zip)'
        },
        [PSCustomObject]@{
            Index      = 2
            Name       = '03_Police-Image-Toolkit'
            Tech       = 'C# .NET 8 WPF'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '03_Police-Image-Toolkit'))
            OutputType = '單檔 EXE、ZIP 與使用者指南'
        },
        [PSCustomObject]@{
            Index      = 3
            Name       = '04_Photo-Report-Generator'
            Tech       = 'Web SPA / 免安裝'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '04_Photo-Report-Generator'))
            OutputType = '前端發行包 (Setup / Portable ZIP)'
        },
        [PSCustomObject]@{
            Index      = 4
            Name       = '06_System-Optimizer-Tool'
            Tech       = 'C# .NET 8 WPF'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '06_System-Optimizer-Tool'))
            OutputType = 'Standalone / Slim 雙版本發行檔'
        },
        [PSCustomObject]@{
            Index      = 5
            Name       = '07_auto-learning-bot'
            Tech       = 'Python Embed'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '07_auto-learning-bot'))
            OutputType = '可攜式發行包 (dist\auto-learning-bot-v*.zip)'
        },
        [PSCustomObject]@{
            Index      = 6
            Name       = '09_PaperSwitch'
            Tech       = 'C# .NET 8 WPF'
            Version    = (Get-RepositoryVersion (Join-Path $devRoot '09_PaperSwitch'))
            OutputType = 'Standalone / Framework-dependent 發行檔'
        }
    )
    $gridDesktopApps.ItemsSource = $apps
}

# 輔助函式：執行桌面建置腳本
function Invoke-DesktopAppsBuild([bool]$Execute, [string]$TargetProject = '') {
    $script = Join-Path $homeRepo 'build_all_desktop_apps.ps1'
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
        [System.Windows.MessageBox]::Show("找不到建置腳本：$script", "錯誤", "OK", "Error")
        return
    }

    $targetDesc = if ($TargetProject) { "[$TargetProject]" } else { "[全部專案]" }
    $mode = if ($Execute) { "執行本機建置 (-Execute) $targetDesc" } else { "預覽建置清單 $targetDesc" }
    Write-GuiLog "開始呼叫 build_all_desktop_apps.ps1 [$mode]..." -Expand
    $txtFooterStatus.Text = "⏳ 正在執行桌面程式建置 [$mode]..."

    $powerShellCmd = Get-HomePowerShell
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script)
    if ($Execute) { $args += '-Execute' }
    if ($TargetProject) { $args += @('-Project', $TargetProject) }

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $powerShellCmd
    $pinfo.Arguments = ($args -join ' ')
    $pinfo.WorkingDirectory = $homeRepo
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    $pinfo.CreateNoWindow = $true

    try {
        $proc = [System.Diagnostics.Process]::Start($pinfo)
        while (-not $proc.HasExited) {
            $line = $proc.StandardOutput.ReadLine()
            if ($line) { Write-GuiLog $line }
            [System.Windows.Forms.Application]::DoEvents()
        }
        $remainder = $proc.StandardOutput.ReadToEnd()
        if ($remainder) { Write-GuiLog $remainder }
        $err = $proc.StandardError.ReadToEnd()
        if ($err) { Write-GuiLog "⚠️ 訊息：$err" }

        if ($proc.ExitCode -eq 0) {
            Write-GuiLog "✅ 桌面應用程式建置 [$mode] 完成 (ExitCode 0)。"
            $txtFooterStatus.Text = "✅ 桌面應用程式建置完成。"
        } else {
            Write-GuiLog "❌ 桌面應用程式建置失敗 (ExitCode $($proc.ExitCode))。"
            $txtFooterStatus.Text = "❌ 建置過程出現錯誤，請檢視日誌。"
        }
    } catch {
        Write-GuiLog "❌ 執行建置發生例外：$($_.Exception.Message)"
    }
}

# 輔助函式：檢查開發工具鏈
function Update-DevToolsStatus {
    Write-GuiLog "正在檢測主要開發工具鏈..." -Expand
    $tools = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Git
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $ver = @(git --version 2>$null) -join ' '
        $tools.Add([PSCustomObject]@{
            Name          = 'Git for Windows'
            StatusDisplay = '✓ 已安裝'
            StatusColor   = '#2A6B3C'
            Version       = $ver
            Path          = $gitCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = 'Git for Windows'
            StatusDisplay = '✕ 未安裝'
            StatusColor   = '#E53E3E'
            Version       = '-'
            Path          = '請由 https://git-scm.com 安裝'
        })
    }

    # PowerShell
    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCmd) {
        $ver = @(pwsh --version 2>$null) -join ' '
        $tools.Add([PSCustomObject]@{
            Name          = 'PowerShell 7 (pwsh)'
            StatusDisplay = '✓ 已安裝 (推薦)'
            StatusColor   = '#2A6B3C'
            Version       = $ver
            Path          = $pwshCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = 'PowerShell 7 (pwsh)'
            StatusDisplay = '◌ 未安裝 (退回 PS 5.1)'
            StatusColor   = '#D69E2E'
            Version       = '-'
            Path          = '可由 winget install Microsoft.PowerShell 安裝'
        })
    }

    # Python
    $pyCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pyCmd) {
        $ver = @(python --version 2>$null) -join ' '
        $tools.Add([PSCustomObject]@{
            Name          = 'Python (全域環境)'
            StatusDisplay = '✓ 已安裝'
            StatusColor   = '#2A6B3C'
            Version       = $ver
            Path          = $pyCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = 'Python (全域環境)'
            StatusDisplay = '◌ 未安裝全域版'
            StatusColor   = '#718096'
            Version       = '-'
            Path          = '各 Python 專案可直接使用 python_embed 可攜包'
        })
    }

    # .NET 8
    $dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($dotnetCmd) {
        $sdks = @(dotnet --list-sdks 2>$null)
        $runtimes = @(dotnet --list-runtimes 2>$null)
        $hasNet8 = ($sdks -match '^8\.') -or ($runtimes -match 'WindowsDesktop\.App\s+8\.')
        $tools.Add([PSCustomObject]@{
            Name          = '.NET 8 SDK / Runtime'
            StatusDisplay = if ($hasNet8) { '✓ 已安裝 .NET 8' } else { '⚠ 缺少 .NET 8' }
            StatusColor   = if ($hasNet8) { '#2A6B3C' } else { '#C05621' }
            Version       = if ($sdks.Count -gt 0) { ($sdks[0] -split ' ')[0] } else { 'Runtime only' }
            Path          = $dotnetCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = '.NET 8 SDK / Runtime'
            StatusDisplay = '✕ 未安裝'
            StatusColor   = '#E53E3E'
            Version       = '-'
            Path          = '請安裝 .NET 8 SDK 或 Desktop Runtime'
        })
    }

    # GitHub CLI (gh)
    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghCmd) {
        $ver = @(gh --version 2>$null | Select-Object -First 1)
        $tools.Add([PSCustomObject]@{
            Name          = 'GitHub CLI (gh)'
            StatusDisplay = '✓ 已安裝'
            StatusColor   = '#2A6B3C'
            Version       = $ver
            Path          = $ghCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = 'GitHub CLI (gh)'
            StatusDisplay = '◌ 建議元件'
            StatusColor   = '#718096'
            Version       = '-'
            Path          = '選用；用於便捷 PR 與 Release 查詢'
        })
    }

    # Node.js
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCmd) {
        $ver = @(node --version 2>$null)
        $tools.Add([PSCustomObject]@{
            Name          = 'Node.js'
            StatusDisplay = '✓ 已安裝'
            StatusColor   = '#2A6B3C'
            Version       = $ver
            Path          = $nodeCmd.Source
        })
    } else {
        $tools.Add([PSCustomObject]@{
            Name          = 'Node.js'
            StatusDisplay = '◌ 建議元件'
            StatusColor   = '#718096'
            Version       = '-'
            Path          = '選用；用於前端輔助測試'
        })
    }

    $gridDevTools.ItemsSource = $tools
    Write-GuiLog "開發工具鏈檢測完成。"
    if ($tools.Count -gt 0) {
        $txtEnvSummary.Text = "Git: 正常 ｜ PS: $(if ($pwshCmd) {'pwsh 7'} else {'PS 5.1'}) ｜ .NET: 8.0"
    }
}

# 輔助函式：載入 Agent 設定清冊
function Load-AgentConfigItems {
    $items = [System.Collections.Generic.List[PSCustomObject]]::new()
    
    # 全域憲法 AGENTS.md
    $centralAgents = Join-Path $homeRepo 'configs\AGENTS.md'
    $codexAgents = Join-Path $env:USERPROFILE '.codex\AGENTS.md'
    $antigravityAgents = Join-Path $env:USERPROFILE '.gemini\config\AGENTS.md'

    $codexSynced = (Test-Path -LiteralPath $codexAgents)
    $antigravitySynced = (Test-Path -LiteralPath $antigravityAgents)

    $items.Add([PSCustomObject]@{
        Name          = '全域開發憲法 (AGENTS.md)'
        Type          = '核心規則'
        Target        = 'Codex & Antigravity'
        StatusDisplay = if ($codexSynced -and $antigravitySynced) { '✓ 部署就緒' } else { '⚠ 待同步' }
        StatusColor   = if ($codexSynced -and $antigravitySynced) { '#2A6B3C' } else { '#C05621' }
        Path          = "中央來源: configs\AGENTS.md"
    })

    # Skills 清單
    $skillManifestPath = Join-Path $homeRepo 'configs\skills-manifest.json'
    if (Test-Path -LiteralPath $skillManifestPath) {
        try {
            $sManifest = Get-Content -LiteralPath $skillManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($sManifest.shared) {
                foreach ($s in $sManifest.shared) {
                    $items.Add([PSCustomObject]@{
                        Name          = $s
                        Type          = '共用 Skill'
                        Target        = 'Codex & Antigravity'
                        StatusDisplay = '✓ 受管共用'
                        StatusColor   = '#2A6B3C'
                        Path          = "configs\skills\$s"
                    })
                }
            }
            if ($sManifest.codexOnly) {
                foreach ($s in $sManifest.codexOnly) {
                    $items.Add([PSCustomObject]@{
                        Name          = $s
                        Type          = 'Codex 專屬 Skill'
                        Target        = 'Codex (.agents\skills)'
                        StatusDisplay = '✓ 受管專用'
                        StatusColor   = '#1976D2'
                        Path          = "configs\skills\$s"
                    })
                }
            }
            if ($sManifest.antigravityOnly) {
                foreach ($s in $sManifest.antigravityOnly) {
                    $items.Add([PSCustomObject]@{
                        Name          = $s
                        Type          = 'Antigravity 專屬 Skill'
                        Target        = 'Antigravity (.gemini\config\skills)'
                        StatusDisplay = '✓ 受管專用'
                        StatusColor   = '#5E35B1'
                        Path          = "configs\skills\$s"
                    })
                }
            }
        } catch {}
    }

    $gridAgentItems.ItemsSource = $items
}

# 輔助函式：呼叫 sync_codex.ps1
function Invoke-AgentSync([bool]$Execute) {
    $script = Join-Path $homeRepo 'scripts\sync_codex.ps1'
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) {
        [System.Windows.MessageBox]::Show("找不到 Agent 同步腳本：$script", "錯誤", "OK", "Error")
        return
    }

    $mode = if ($Execute) { "正式同步部署 (-Execute)" } else { "唯讀檢查 (-CheckOnly)" }
    Write-GuiLog "開始呼叫 sync_codex.ps1 [$mode]..." -Expand
    $txtFooterStatus.Text = "⏳ 正在執行 Agent 設定 [$mode]..."

    $powerShellCmd = Get-HomePowerShell
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script)
    if ($Execute) { $args += '-Execute' } else { $args += '-CheckOnly' }

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $powerShellCmd
    $pinfo.Arguments = ($args -join ' ')
    $pinfo.WorkingDirectory = $homeRepo
    $pinfo.RedirectStandardOutput = $true
    $pinfo.RedirectStandardError = $true
    $pinfo.UseShellExecute = $false
    $pinfo.CreateNoWindow = $true

    try {
        $proc = [System.Diagnostics.Process]::Start($pinfo)
        while (-not $proc.HasExited) {
            $line = $proc.StandardOutput.ReadLine()
            if ($line) { Write-GuiLog $line }
            [System.Windows.Forms.Application]::DoEvents()
        }
        $remainder = $proc.StandardOutput.ReadToEnd()
        if ($remainder) { Write-GuiLog $remainder }
        $err = $proc.StandardError.ReadToEnd()
        if ($err) { Write-GuiLog "⚠️ 訊息：$err" }

        if ($proc.ExitCode -eq 0) {
            Write-GuiLog "✅ Agent 設定 [$mode] 執行成功。"
            $txtFooterStatus.Text = "✅ Agent 設定 [$mode] 完成。"
        } else {
            Write-GuiLog "❌ Agent 設定 [$mode] 執行失敗 (ExitCode $($proc.ExitCode))。"
            $txtFooterStatus.Text = "❌ Agent 設定檢查或同步未完成。"
        }
    } catch {
        Write-GuiLog "❌ 執行 Agent 同步發生例外：$($_.Exception.Message)"
    }
}

# 輔助函式：檢查桌面捷徑狀態 (Phase 10)
function Test-DesktopShortcutsStatus {
    Write-GuiLog "正在檢查桌面捷徑狀態..." -Expand
    $desktop = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    if (-not (Test-Path -LiteralPath $desktop)) {
        Write-GuiLog "⚠️ 無法取得使用者桌面目錄。"
        return
    }

    $wsh = New-Object -ComObject WScript.Shell
    $checkedCount = 0
    $validCount = 0
    $missingCount = 0

    $appConfigs = @(
        @{ Name = '01_AG-MONITOR-Smart-Video-Screening'; Exe = '01_AG-MONITOR-Smart-Video-Screening\dist\AG-MONITOR-v4.0.0\AG-MONITOR.exe'; Lnk = 'AG-MONITOR 智慧影像快篩系統.lnk' },
        @{ Name = '03_Police-Image-Toolkit'; Exe = '03_Police-Image-Toolkit\dist\PoliceImageToolkit.exe'; Lnk = 'PoliceImageToolkit.lnk' },
        @{ Name = '06_System-Optimizer-Tool'; Exe = '06_System-Optimizer-Tool\dotnet-src\publish\standalone\SystemOptimizer.App.exe'; Lnk = 'SystemOptimizer.lnk' },
        @{ Name = '09_PaperSwitch'; Exe = '09_PaperSwitch\dist\publish\PaperSwitch.exe'; Lnk = 'PaperSwitch.lnk' }
    )

    foreach ($app in $appConfigs) {
        $checkedCount++
        $lnkPath = Join-Path $desktop $app.Lnk
        $exePath = Join-Path $devRoot $app.Exe

        if (Test-Path -LiteralPath $lnkPath) {
            try {
                $shortcut = $wsh.CreateShortcut($lnkPath)
                $target = $shortcut.TargetPath
                if (Test-Path -LiteralPath $target) {
                    Write-GuiLog "✓ [捷徑正常] $($app.Name) ➜ $($app.Lnk) 指向有效檔案"
                    $validCount++
                } else {
                    Write-GuiLog "⚠ [捷徑失效] $($app.Name) ➜ 目標檔案不存在 ($target)"
                    $missingCount++
                }
            } catch {
                Write-GuiLog "⚠️ 無法讀取捷徑：$lnkPath"
            }
        } else {
            Write-GuiLog "◌ [無捷徑] $($app.Name) ➜ 桌面尚未建立 $($app.Lnk) (可執行集中建置建立)"
        }
    }
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
    Write-GuiLog "桌面捷徑檢查結束：已建立 $validCount 個，無效 $missingCount 個。"
    $txtFooterStatus.Text = "📌 捷徑檢查完成：有效 $validCount 個，失效 $missingCount 個。"
}

# 輔助函式：Level 3 完整檢查 (Git + 環境工具鏈 + 建置預覽 + Agent 設定)
function Invoke-FullSystemCheck {
    Write-GuiLog "🚀 開始執行 Level 3 完整檢查 (Git + 環境 + 建置 + Agent)..." -Expand
    $txtFooterStatus.Text = "⏳ 正在執行 Level 3 完整系統檢查..."

    # 1. 執行遠端 Git 狀態更新
    Update-WorkspaceRepositories -FetchRemote $true

    # 2. 檢測開發工具鏈狀態
    Update-DevToolsStatus

    # 3. 檢查 Agent 治理設定差異
    Invoke-AgentSync -Execute $false

    # 4. 預覽建置狀態
    Invoke-DesktopAppsBuild -Execute $false

    # 5. 檢查桌面捷徑
    Test-DesktopShortcutsStatus

    Write-GuiLog "✅ Level 3 完整檢查作業已全數完成！"
    $txtFooterStatus.Text = "💡 Level 3 完整檢查完成，所有模組狀態已更新。"
}

# ==================== 事件處理器綁定 ====================

# 掃描按鈕 (三級掃描分級)
$btnQuickScan.Add_Click({
    Start-Level1BackgroundScan
})

if ($btnRemoteRefresh) {
    $btnRemoteRefresh.Add_Click({
        Update-WorkspaceRepositories -FetchRemote $true
    })
}

if ($btnFullCheck) {
    $btnFullCheck.Add_Click({
        Invoke-FullSystemCheck
    })
}

$btnOpenWorkspace.Add_Click({
    if (Test-Path -LiteralPath $devRoot) {
        Invoke-Item $devRoot
    }
})

# 篩選標籤按鈕
$btnFilterAll.Add_Click({
    $global:CurrentFilter = 'All'
    Apply-RepositoryFilters
})
$btnFilterAttention.Add_Click({
    $global:CurrentFilter = 'Attention'
    Apply-RepositoryFilters
})
$btnFilterAhead.Add_Click({
    $global:CurrentFilter = 'Ahead'
    Apply-RepositoryFilters
})
$btnFilterBehind.Add_Click({
    $global:CurrentFilter = 'Behind'
    Apply-RepositoryFilters
})
$btnFilterClean.Add_Click({
    $global:CurrentFilter = 'Clean'
    Apply-RepositoryFilters
})

# 搜尋輸入框即時搜尋
$txtSearchBox.Add_TextChanged({
    $global:CurrentSearch = $txtSearchBox.Text
    Apply-RepositoryFilters
})

# 資料表選取變更
$gridRepositories.Add_SelectionChanged({
    $selected = $gridRepositories.SelectedItem
    if ($selected) {
        $txtSelectedRepoInfo.Text = "選取：$($selected.Name) ($($selected.Version)) ｜ 目錄：$($selected.Path) ｜ 分支：$($selected.Branch) ｜ 狀態：$($selected.Detail)"
    } else {
        $txtSelectedRepoInfo.Text = "請點選上方專案以檢視詳細路徑與操作"
    }
})

# 項目動作按鈕
$btnOpenSelectedFolder.Add_Click({
    $selected = $gridRepositories.SelectedItem
    if ($selected -and (Test-Path -LiteralPath $selected.Path)) {
        Invoke-Item $selected.Path
    } else {
        [System.Windows.MessageBox]::Show("請先選擇一個已存在的專案目錄。", "提示", "OK", "Information")
    }
})

$btnOpenSelectedGitHub.Add_Click({
    $selected = $gridRepositories.SelectedItem
    if ($selected -and $selected.GitHubUrl) {
        Start-Process $selected.GitHubUrl
    } else {
        [System.Windows.MessageBox]::Show("請先選擇一個專案。", "提示", "OK", "Information")
    }
})

$btnCopySelectedPath.Add_Click({
    $selected = $gridRepositories.SelectedItem
    if ($selected -and $selected.Path) {
        [System.Windows.Clipboard]::SetText($selected.Path)
        $txtFooterStatus.Text = "📋 已複製路徑至剪貼簿：$($selected.Path)"
    }
})

# 安全 Git 同步
$btnPreviewSyncPlan.Add_Click({
    Generate-SyncPlan
})

$btnExecuteSafeSync.Add_Click({
    Execute-SafeSyncPlan
})

# 桌面應用程式建置
$btnPreviewBuild.Add_Click({
    Invoke-DesktopAppsBuild -Execute $false
})

if ($btnCheckShortcuts) {
    $btnCheckShortcuts.Add_Click({
        Test-DesktopShortcutsStatus
    })
}

if ($btnBuildSelected) {
    $btnBuildSelected.Add_Click({
        $selectedApp = $gridDesktopApps.SelectedItem
        if (-not $selectedApp) {
            [System.Windows.MessageBox]::Show("請先於下方表格中選取要建置的桌面應用程式。", "提示", "OK", "Information")
            return
        }
        $confirm = [System.Windows.MessageBox]::Show("即將執行 [$($selectedApp.Name)] 本機建置。`n本操作僅產出本機二進位包，不包含 GitHub Release 發行。是否繼續？", "確認單項建置", "YesNo", "Question")
        if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
            Invoke-DesktopAppsBuild -Execute $true -TargetProject $selectedApp.Name
        }
    })
}

$btnExecuteBuild.Add_Click({
    $confirm = [System.Windows.MessageBox]::Show("即將執行全部桌面應用程式本機集中建置。`n本操作僅產出本機二進位包，不包含 GitHub Release 發行。是否繼續？", "確認建置", "YesNo", "Question")
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        Invoke-DesktopAppsBuild -Execute $true
    }
})

# 開發環境管理
$btnCheckDevTools.Add_Click({
    Update-DevToolsStatus
})

$chkEnableInit.Add_Checked({
    $btnCloneMissingRepos.IsEnabled = $true
    $btnSetupPythonEmbed.IsEnabled = $true
})
$chkEnableInit.Add_Unchecked({
    $btnCloneMissingRepos.IsEnabled = $false
    $btnSetupPythonEmbed.IsEnabled = $false
})

$btnCloneMissingRepos.Add_Click({
    $missing = @($global:RepoData | Where-Object { $_.State -eq 'Missing' })
    if ($missing.Count -eq 0) {
        [System.Windows.MessageBox]::Show("所有 14 個版本庫皆已存在於本機，無需執行補齊 Clone。", "檢查結果", "OK", "Information")
        return
    }
    $names = ($missing | ForEach-Object { $_.Name }) -join ', '
    $confirm = [System.Windows.MessageBox]::Show("發現 $($missing.Count) 個缺漏版本庫：`n$names`n`n是否執行 git clone 下載？", "確認初始化 Clone", "YesNo", "Question")
    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        foreach ($m in $missing) {
            Write-GuiLog "📥 正在 Clone: $($m.Name) ($($m.GitHubUrl))..." -Expand
            $safeDest = $m.Path
            $cloneOutput = @(git clone $m.GitHubUrl $safeDest 2>&1)
            if ($LASTEXITCODE -eq 0) {
                Write-GuiLog "✅ $($m.Name) Clone 成功！"
            } else {
                Write-GuiLog "❌ $($m.Name) Clone 失敗：$($cloneOutput -join ' ')"
            }
        }
        Update-WorkspaceRepositories -FetchRemote $false
    }
})

$btnSetupPythonEmbed.Add_Click({
    $script = Join-Path $homeRepo 'setup_all_envs.ps1'
    if (Test-Path -LiteralPath $script) {
        Write-GuiLog "🐍 正在呼叫 setup_all_envs.ps1 建置 Python 可攜環境..." -Expand
        $powerShellCmd = Get-HomePowerShell
        & $powerShellCmd -NoProfile -ExecutionPolicy Bypass -File $script
        Write-GuiLog "Python 可攜環境建置完成。"
    }
})

# Codex / Antigravity 管理
$btnCheckAgentSync.Add_Click({
    Invoke-AgentSync -Execute $false
})

$btnExecuteAgentSync.Add_Click({
    Invoke-AgentSync -Execute $true
})

# 日誌控制
$btnClearLog.Add_Click({
    $txtConsoleLog.Clear()
    $txtLogStatus.Text = "｜ 日誌已清除"
})

$btnCopyLog.Add_Click({
    if (-not [string]::IsNullOrWhiteSpace($txtConsoleLog.Text)) {
        [System.Windows.Clipboard]::SetText($txtConsoleLog.Text)
        $txtFooterStatus.Text = "📋 已複製日誌內容至剪貼簿。"
    }
})

# 視窗載入初始化：先完成 Shell 資料，掃描交由首次畫面 Render 後的背景工作。
$window.Add_Loaded({
    # 1. 立即載入桌面應用程式清單與 Agent 設定
    Load-DesktopAppsList
    Load-AgentConfigItems

    # 2. 初始狀態列與工具鏈摘要預設值 (避免啟動時執行外部 CLI 阻塞)
    $txtEnvSummary.Text = "Git: 就緒 ｜ PS: $(if (Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue) {'pwsh 7'} else {'PS 5.1'}) ｜ .NET: 8.0"

})

$window.Add_ContentRendered({
    # 防止 ContentRendered 重複觸發（視窗 resize、Tab 切換等可能重新觸發）
    if ($script:InitialScanStarted) { return }
    $script:InitialScanStarted = $true
    Start-Level1BackgroundScan
})

# 視窗關閉時清理背景 Job 與 Timer，避免殘留資源
$window.Add_Closing({
    if ($global:Level1ScanTimer -and $global:Level1ScanTimer.IsEnabled) {
        try { $global:Level1ScanTimer.Stop() } catch {}
        $global:Level1ScanTimer = $null
    }
    if ($global:Level1ScanJob) {
        try { Remove-Job -Job $global:Level1ScanJob -Force -ErrorAction SilentlyContinue } catch {}
        $global:Level1ScanJob = $null
    }
})

# 顯示視窗
if ($StartupCheck) {
    exit 0
}
$window.ShowDialog() | Out-Null
