[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\bootstrap.ps1')
. (Join-Path $PSScriptRoot '..\lib\git-status.ps1')

function Invoke-NativeGit {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    # Git 會將正常進度寫入 stderr；在 Stop 模式下暫切換為 Continue，改以 ExitCode 判定結果
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }
    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = @($output)
    }
}

function Invoke-TestGit {
    param([Parameter(Mandatory = $true)][string]$Repository, [Parameter(Mandatory = $true)][string[]]$Arguments)
    $result = Invoke-NativeGit -Arguments (@('-C', $Repository) + $Arguments)
    if ($result.ExitCode -ne 0) {
        throw "Git 指令失敗：git -C $Repository $($Arguments -join ' ')`n$($result.Output -join [Environment]::NewLine)"
    }
}

function New-TestClone {
    param([Parameter(Mandatory = $true)][string]$Remote, [Parameter(Mandatory = $true)][string]$Destination)
    $result = Invoke-NativeGit -Arguments @('clone', '--quiet', $Remote, $Destination)
    if ($result.ExitCode -ne 0) { throw "無法建立測試版本庫：$($result.Output -join [Environment]::NewLine)" }
    Invoke-TestGit -Repository $Destination -Arguments @('config', 'user.email', '00-dev-control-center-test@example.invalid')
    Invoke-TestGit -Repository $Destination -Arguments @('config', 'user.name', 'Dev-Control-Center 測試')
}

function Assert-RepositoryState {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Expected
    )
    $actual = Get-ManagedRepositoryStatus -RepositoryPath $Path
    if ($actual.State -ne $Expected) {
        throw "狀態測試失敗 [$Name]：預期 $Expected，實際 $($actual.State)（$($actual.Detail)）"
    }
    Write-Output "[通過] $Name : $($actual.Detail)"
}

$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("dev-control-center-git-status-" + [Guid]::NewGuid().ToString('N'))
try {
    $remote = Join-Path $testRoot 'remote.git'
    $seed = Join-Path $testRoot 'seed'
    $candidate = Join-Path $testRoot 'candidate'
    $behind = Join-Path $testRoot 'behind'
    New-Item -ItemType Directory -Path $testRoot | Out-Null
    $initBare = Invoke-NativeGit -Arguments @('init', '--bare', $remote)
    if ($initBare.ExitCode -ne 0) { throw "無法建立測試遠端版本庫：$($initBare.Output -join [Environment]::NewLine)" }
    $initSeed = Invoke-NativeGit -Arguments @('init', $seed)
    if ($initSeed.ExitCode -ne 0) { throw "無法建立測試工作版本庫：$($initSeed.Output -join [Environment]::NewLine)" }
    Invoke-TestGit -Repository $seed -Arguments @('config', 'user.email', '00-dev-control-center-test@example.invalid')
    Invoke-TestGit -Repository $seed -Arguments @('config', 'user.name', 'Dev-Control-Center 測試')
    Invoke-TestGit -Repository $seed -Arguments @('branch', '-M', 'main')
    [IO.File]::WriteAllText((Join-Path $seed 'state.txt'), 'base', [Text.UTF8Encoding]::new($false))
    Invoke-TestGit -Repository $seed -Arguments @('add', 'state.txt')
    Invoke-TestGit -Repository $seed -Arguments @('commit', '-m', 'test: 建立狀態基準')
    Invoke-TestGit -Repository $seed -Arguments @('remote', 'add', 'origin', $remote)
    Invoke-TestGit -Repository $seed -Arguments @('push', '-u', 'origin', 'main')
    Invoke-TestGit -Repository $remote -Arguments @('symbolic-ref', 'HEAD', 'refs/heads/main')
    New-TestClone -Remote $remote -Destination $candidate
    New-TestClone -Remote $remote -Destination $behind

    # 1. 驗證 Clean
    Assert-RepositoryState -Name 'Clean' -Path $candidate -Expected 'Clean'

    # 2. 驗證 Modified
    [IO.File]::AppendAllText((Join-Path $candidate 'state.txt'), "`nmodified", [Text.UTF8Encoding]::new($false))
    Assert-RepositoryState -Name 'Modified' -Path $candidate -Expected 'Modified'

    # 3. 驗證 Ahead
    Invoke-TestGit -Repository $candidate -Arguments @('add', 'state.txt')
    Invoke-TestGit -Repository $candidate -Arguments @('commit', '-m', 'test: 本機待推送')
    Assert-RepositoryState -Name 'Ahead' -Path $candidate -Expected 'Ahead'

    # 4. 驗證 Behind
    [IO.File]::AppendAllText((Join-Path $seed 'state.txt'), "`nremote", [Text.UTF8Encoding]::new($false))
    Invoke-TestGit -Repository $seed -Arguments @('add', 'state.txt')
    Invoke-TestGit -Repository $seed -Arguments @('commit', '-m', 'test: 遠端更新')
    Invoke-TestGit -Repository $seed -Arguments @('push')
    Invoke-TestGit -Repository $behind -Arguments @('fetch', 'origin')
    Assert-RepositoryState -Name 'Behind' -Path $behind -Expected 'Behind'

    # 5. 驗證 Diverged
    Invoke-TestGit -Repository $candidate -Arguments @('fetch', 'origin')
    Assert-RepositoryState -Name 'Diverged' -Path $candidate -Expected 'Diverged'

    # 6. 驗證 Missing
    Assert-RepositoryState -Name 'Missing' -Path (Join-Path $testRoot 'missing') -Expected 'Missing'

    Write-Output 'Git 狀態分類測試全部通過。'
} finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
