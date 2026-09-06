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
        $result.Detail = '目錄不存在'
        return [PSCustomObject]$result
    }
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryPath '.git'))) {
        $result.State = 'Error'
        $result.Detail = '目錄不是 Git 版本庫'
        return [PSCustomObject]$result
    }

    $safePath = $RepositoryPath.Replace('\', '/')
    $changes = @(git -c "safe.directory=$safePath" -C $RepositoryPath status --porcelain 2>$null)
    if ($LASTEXITCODE -ne 0) {
        $result.Detail = '無法讀取工作目錄狀態'
        return [PSCustomObject]$result
    }
    $result.ModifiedFiles = $changes.Count

    $branch = @(git -c "safe.directory=$safePath" -C $RepositoryPath branch --show-current 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $branch -or [string]::IsNullOrWhiteSpace([string]$branch[0])) {
        $result.Detail = '目前不在可同步的本機分支'
        return [PSCustomObject]$result
    }
    $result.Branch = ([string]$branch[0]).Trim()

    $upstream = @(git -c "safe.directory=$safePath" -C $RepositoryPath rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $upstream) {
        $result.Detail = '目前分支未設定上游，已停止自動同步'
        return [PSCustomObject]$result
    }
    $result.Upstream = ([string]$upstream[0]).Trim()

    $counts = @(git -c "safe.directory=$safePath" -C $RepositoryPath rev-list --left-right --count 'HEAD...@{upstream}' 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $counts -or ([string]$counts[0]) -notmatch '^(\d+)\s+(\d+)$') {
        $result.Detail = '無法比較本機與上游提交'
        return [PSCustomObject]$result
    }
    $result.Ahead = [int]$matches[1]
    $result.Behind = [int]$matches[2]

    if ($result.ModifiedFiles -gt 0) {
        $result.State = 'Modified'
        $result.Detail = "未提交 $($result.ModifiedFiles) 個檔案；已停止自動 Pull／Push"
    } elseif ($result.Ahead -gt 0 -and $result.Behind -gt 0) {
        $result.State = 'Diverged'
        $result.Detail = "本機 +$($result.Ahead)，遠端 +$($result.Behind)；需人工合併"
    } elseif ($result.Ahead -gt 0) {
        $result.State = 'Ahead'
        $result.Detail = "↑ $($result.Ahead) 個提交待 Push"
    } elseif ($result.Behind -gt 0) {
        $result.State = 'Behind'
        $result.Detail = "↓ $($result.Behind) 個提交待 Pull"
    } else {
        $result.State = 'Synced'
        $result.Detail = '✓ 已同步'
    }

    return [PSCustomObject]$result
}
