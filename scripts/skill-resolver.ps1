# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$TargetRepository = '',
    [switch]$Detailed,
    [switch]$IgnoreUserConfig
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$resolvedSource = $null
$resolvedSkillHome = $null
$resolvedControlCenter = $null

# 1. 優先檢查環境變數 LIANGHAO_SKILL_HOME
if (-not [string]::IsNullOrWhiteSpace($env:LIANGHAO_SKILL_HOME)) {
    if (Test-Path -LiteralPath $env:LIANGHAO_SKILL_HOME) {
        $resolvedSkillHome = [IO.Path]::GetFullPath($env:LIANGHAO_SKILL_HOME)
        $resolvedSource = 'EnvironmentVariable (LIANGHAO_SKILL_HOME)'
        $resolvedControlCenter = Split-Path -Parent (Split-Path -Parent $resolvedSkillHome)
    }
}

# 2. 檢查使用者本機設定檔 %USERPROFILE%\.lianghao\config.json
if ($null -eq $resolvedSkillHome -and -not $IgnoreUserConfig) {
    $userConfig = Join-Path $env:USERPROFILE '.lianghao\config.json'
    if (Test-Path -LiteralPath $userConfig -PathType Leaf) {
        try {
            $config = Get-Content -LiteralPath $userConfig -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($config.PSObject.Properties['skillHome'] -and (Test-Path -LiteralPath $config.skillHome)) {
                $resolvedSkillHome = [IO.Path]::GetFullPath($config.skillHome)
                $resolvedSource = 'UserConfig (%USERPROFILE%\.lianghao\config.json:skillHome)'
                if ($config.PSObject.Properties['controlCenterPath'] -and (Test-Path -LiteralPath $config.controlCenterPath)) {
                    $resolvedControlCenter = [IO.Path]::GetFullPath($config.controlCenterPath)
                } else {
                    $resolvedControlCenter = Split-Path -Parent (Split-Path -Parent $resolvedSkillHome)
                }
            } elseif ($config.PSObject.Properties['controlCenterPath'] -and (Test-Path -LiteralPath $config.controlCenterPath)) {
                $candidate = Join-Path $config.controlCenterPath 'skills\lianghao-development'
                if (Test-Path -LiteralPath $candidate) {
                    $resolvedSkillHome = [IO.Path]::GetFullPath($candidate)
                    $resolvedSource = 'UserConfig (%USERPROFILE%\.lianghao\config.json:controlCenterPath)'
                    $resolvedControlCenter = [IO.Path]::GetFullPath($config.controlCenterPath)
                }
            }
        } catch {
            Write-Warning "讀取本機設定失敗 ($userConfig)：$($_.Exception.Message)"
        }
    }
}

# 3. 鄰近目錄自動探索 (若從 TargetRepository 或目前工作目錄出發)
if ($null -eq $resolvedSkillHome) {
    $searchOrigins = @()
    if (-not [string]::IsNullOrWhiteSpace($TargetRepository) -and (Test-Path -LiteralPath $TargetRepository)) {
        $searchOrigins += (Resolve-Path $TargetRepository).Path
    } else {
        $searchOrigins += (Get-Location).Path
    }
    if ($searchOrigins -notcontains $PSScriptRoot) {
        $searchOrigins += $PSScriptRoot
    }

    foreach ($origin in $searchOrigins) {
        $current = $origin
        while ($null -ne $current -and $current -ne '') {
            $candidates = @(
                (Join-Path $current 'skills\lianghao-development'),
                (Join-Path $current '00_Dev-Control-Center\skills\lianghao-development'),
                (Join-Path $current 'Dev-Control-Center\skills\lianghao-development')
            )
            foreach ($c in $candidates) {
                if (Test-Path -LiteralPath $c) {
                    $resolvedSkillHome = [IO.Path]::GetFullPath($c)
                    $resolvedSource = "WorkspaceDiscovery ($origin)"
                    $resolvedControlCenter = Split-Path -Parent (Split-Path -Parent $resolvedSkillHome)
                    break
                }
            }
            if ($null -ne $resolvedSkillHome) { break }
            $parent = Split-Path -Parent $current
            if ($parent -eq $current) { break }
            $current = $parent
        }
        if ($null -ne $resolvedSkillHome) { break }
    }
}

if ($null -eq $resolvedSkillHome) {
    if ($Detailed) {
        return [PSCustomObject]@{
            Status = 'NOT FOUND'
            SkillHome = $null
            Version = $null
            Source = $null
            ControlCenterPath = $null
        }
    } else {
        throw "NOT FOUND: 無法解析 lianghao-development Skill 路徑。請檢查 LIANGHAO_SKILL_HOME 或 %USERPROFILE%\.lianghao\config.json。"
    }
}

$versionFile = Join-Path $resolvedSkillHome 'VERSION'
$version = if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
    (Get-Content -LiteralPath $versionFile -Raw -Encoding UTF8).Trim()
} else {
    'Unknown'
}

$result = [PSCustomObject]@{
    Status = 'FOUND'
    SkillHome = $resolvedSkillHome
    Version = $version
    Source = $resolvedSource
    ControlCenterPath = $resolvedControlCenter
}

if ($Detailed) {
    return $result
} else {
    Write-Output $resolvedSkillHome
}
