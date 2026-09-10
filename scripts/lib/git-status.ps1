function Get-ManagedRepositoryStatus {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryPath
    )

    $result = [ordered]@{
        Path = $RepositoryPath
        Branch = $null
        Upstream = $null
        State = 'Error'
        Ahead = 0
        Behind = 0
        ModifiedFiles = 0
        Detail = ''
    }

    if (-not (Test-Path -LiteralPath $RepositoryPath)) {
        $result.State = 'Missing'
        $result.Detail = '目錄不存在 (Missing Repository)'
        return [PSCustomObject]$result
    }
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryPath '.git'))) {
        $result.State = 'Error'
        $result.Detail = '目錄不是 Git 版本庫'
        return [PSCustomObject]$result
    }

    $safePath = $RepositoryPath.Replace('\', '/')
    # porcelain v2 的 branch 標頭同時提供分支、上游與領先／落後資訊，
    # 避免每個 Repository 額外啟動 branch、rev-parse、rev-list 三個 Git 程序。
    # 直接呼叫 git.exe，避免 PowerShell → cmd.exe → git.exe 的額外中介層。
    # Windows PowerShell 5.1 會將 Git 的非致命 stderr 警告升格為錯誤記錄；
    # 此處只以 Git 結束代碼判定成功與否，避免單一版本庫警告中斷整批掃描。
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $gitOutput = @(& git -c "safe.directory=$safePath" -C $RepositoryPath status --porcelain=v2 --branch 2>$null)
        $gitExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($gitExitCode -ne 0) {
        $result.State = 'Unknown'
        $result.Detail = '無法讀取工作目錄狀態 (無法確認)'
        return [PSCustomObject]$result
    }
    $changes = @($gitOutput | Where-Object { $_ -notmatch '^# ' })
    $result.ModifiedFiles = $changes.Count

    # 檢查是否有未解決的合併衝突 (Conflict)
    $hasConflict = $false
    foreach ($line in $changes) {
        if ($line -match '^u\s') {
            $hasConflict = $true
            break
        }
    }
    if ($hasConflict) {
        $result.State = 'Conflict'
        $result.Detail = '存在合併衝突；需人工處理，已停止自動處理'
        return [PSCustomObject]$result
    }

    $branchHeader = @($gitOutput | Where-Object { $_ -match '^# branch\.head ' } | Select-Object -First 1)
    if (-not $branchHeader) {
        $result.Detail = '目前不在可同步的本機分支'
        return [PSCustomObject]$result
    }
    $result.Branch = ([string]$branchHeader).Substring('# branch.head '.Length).Trim()
    if ([string]::IsNullOrWhiteSpace($result.Branch) -or $result.Branch -eq '(detached)') {
        $result.Detail = '目前不在可同步的本機分支'
        return [PSCustomObject]$result
    }

    $upstreamHeader = @($gitOutput | Where-Object { $_ -match '^# branch\.upstream ' } | Select-Object -First 1)
    if (-not $upstreamHeader) {
        $result.State = 'Unknown'
        $result.Detail = '目前分支未設定上游；無法確認遠端狀態'
        return [PSCustomObject]$result
    }
    $result.Upstream = ([string]$upstreamHeader).Substring('# branch.upstream '.Length).Trim()

    $aheadBehindHeader = @($gitOutput | Where-Object { $_ -match '^# branch\.ab ' } | Select-Object -First 1)
    if (-not $aheadBehindHeader -or ([string]$aheadBehindHeader) -notmatch '^# branch\.ab \+(\d+) -(\d+)$') {
        $result.State = 'Unknown'
        $result.Detail = '無法比較本機與上游提交 (無法確認)'
        return [PSCustomObject]$result
    }
    $result.Ahead = [int]$matches[1]
    $result.Behind = [int]$matches[2]

    if ($result.ModifiedFiles -gt 0) {
        $result.State = 'Modified'
        $result.Detail = "未提交 $($result.ModifiedFiles) 個檔案；需人工處理，已停止自動處理"
    } elseif ($result.Ahead -gt 0 -and $result.Behind -gt 0) {
        $result.State = 'Diverged'
        $result.Detail = "本機 +$($result.Ahead)，遠端 +$($result.Behind)；分歧需人工合併"
    } elseif ($result.Ahead -gt 0) {
        $result.State = 'Ahead'
        $result.Detail = "$($result.Ahead) 個提交待 Push (待上傳)"
    } elseif ($result.Behind -gt 0) {
        $result.State = 'Behind'
        $result.Detail = "$($result.Behind) 個提交待 Pull (待下載)"
    } else {
        $result.State = 'Clean'
        $result.Detail = '已同步 (Clean)'
    }

    return [PSCustomObject]$result
}
