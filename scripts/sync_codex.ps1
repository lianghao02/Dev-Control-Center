# UTF-8 Compatibility
[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [switch]$Force,
    [switch]$PruneBackups,
    [switch]$Execute,
    [switch]$SkipMcpConfig
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path $PSScriptRoot 'lib\bootstrap.ps1')
. (Join-Path $PSScriptRoot 'lib\skill-deployment.ps1')

if (-not $Execute -and -not $Force -and -not $CheckOnly) {
    $CheckOnly = $true
}

$homeRepo = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($homeRepo)) {
    throw '無法從腳本位置判定控制中心專案根目錄。'
}
$githubRoot = Split-Path -Parent $homeRepo
$codexHome = Join-Path $env:USERPROFILE '.codex'
$antigravityHome = Join-Path $env:USERPROFILE '.gemini\config'
$claudeHome = Join-Path $env:USERPROFILE '.claude'
$manifestPath = Join-Path $codexHome 'antigravity-bridge.json'
$skillPlan = Get-SkillDeploymentPlan $homeRepo $env:USERPROFILE

function Get-TextHash([string]$Content) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($Content)
    $stream = [IO.MemoryStream]::new($bytes)
    try { return (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash }
    finally { $stream.Dispose() }
}

function Get-BackupDirectory([string]$Target) {
    $backupSession = Get-Date -Format 'yyyyMMdd-HHmmss'
    $targetLabel = [regex]::Replace($Target.TrimEnd([char[]]('\', '/')), '[^A-Za-z0-9._-]', '_').Trim('_')
    if ([string]::IsNullOrWhiteSpace($targetLabel)) {
        $targetLabel = 'managed-item'
    }
    return Join-Path $codexHome (Join-Path (Join-Path 'bridge-backups' $backupSession) $targetLabel)
}

function Sync-ManagedItem([string]$Source, [string]$Target, [hashtable]$Old, [hashtable]$New, [object]$Content = $null) {
    if ($null -eq $Content -and -not (Test-Path -LiteralPath $Source)) { throw "Source does not exist: $Source" }
    $sourceHash = if ($null -eq $Content) { Get-TreeHash $Source } else { Get-TextHash $Content }
    $targetHash = if (Test-Path -LiteralPath $Target) { Get-TreeHash $Target } else { $null }
    $knownHash = if ($Old.ContainsKey($Target)) { $Old[$Target] } else { $null }

    $New[$Target] = $sourceHash
    if ($targetHash -eq $sourceHash) { Write-Output "Current: $Target"; return }

    $isEmptyFile = $false
    if ($targetHash -and (Test-Path -LiteralPath $Target -PathType Leaf)) {
        $targetItem = Get-Item -LiteralPath $Target
        if ($targetItem.Length -eq 0) {
            $isEmptyFile = $true
        }
    }

    if ($CheckOnly) {
        if ($targetHash -and -not $knownHash -and -not $isEmptyFile) {
            Write-Warning "Unmanaged (未受管項目，正式同步需 -Force): $Target"
            return
        }
        if ($targetHash -and $knownHash -and $targetHash -ne $knownHash) {
            Write-Warning "Modified (曾被修改，正式同步需 -Force): $Target"
            return
        }
        Write-Output "Pending: $Target"
        return
    }

    if ($targetHash -and -not $knownHash -and -not $Force -and -not $isEmptyFile) {
        throw "Target exists but is not managed; refusing overwrite: $Target"
    }
    if ($targetHash -and $knownHash -and $targetHash -ne $knownHash -and -not $Force) {
        throw "Target was modified after deployment; refusing overwrite: $Target"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $Target) -Force | Out-Null
    if (Test-Path -LiteralPath $Target) {
        $backup = Get-BackupDirectory $Target
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $Target -Destination $backup -Recurse -Force
        $fullTarget = [IO.Path]::GetFullPath($Target)
        $allowedFiles = @((Join-Path $codexHome 'AGENTS.md'), (Join-Path $antigravityHome 'AGENTS.md'), (Join-Path $antigravityHome 'mcp_config.json'), (Join-Path $claudeHome 'CLAUDE.md'))
        $safeSkillTarget = $false
        foreach ($allowedRoot in $skillPlan.Roots.Values) {
            if ($fullTarget.StartsWith([IO.Path]::GetFullPath($allowedRoot).TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) { $safeSkillTarget = $true }
        }
        if ($fullTarget -notin $allowedFiles -and -not $safeSkillTarget) { throw "拒絕移除未受管路徑：$fullTarget" }
        Remove-Item -LiteralPath $fullTarget -Recurse -Force
    }
    if ($null -eq $Content) {
        Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
    } else {
        [IO.File]::WriteAllText($Target, $Content, [Text.UTF8Encoding]::new($false))
    }
    Write-Output "Synced: $Target"
}

$old = @{}
if (Test-Path -LiteralPath $manifestPath) {
    $saved = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($item in $saved.items) { $old[[string]$item.target] = [string]$item.hash }
}
$new = @{}
# 選擇性同步仍保留其他既有受管項目的雜湊。
foreach ($target in $old.Keys) { $new[$target] = $old[$target] }
$items = @(
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $codexHome 'AGENTS.md' },
    @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $antigravityHome 'AGENTS.md' }
)
# Claude Code 以 @ 匯入語法即時讀取中央憲法，憲法修訂後不需重新部署此檔。
$constitutionPath = [IO.Path]::GetFullPath((Join-Path $homeRepo 'configs\AGENTS.md')).Replace('\', '/')
$claudeMdContent = @(
    '<!-- 由 00_Dev-Control-Center\scripts\sync_codex.ps1 產生；請勿手動修改，全域憲法請改 configs/AGENTS.md -->',
    "@$constitutionPath",
    ''
) -join "`n"
$items += @{ Source = Join-Path $homeRepo 'configs\AGENTS.md'; Target = Join-Path $claudeHome 'CLAUDE.md'; Content = $claudeMdContent }
$mcpConfigSrc = Join-Path $homeRepo 'configs\mcp_config.json'
if (-not $SkipMcpConfig -and (Test-Path -LiteralPath $mcpConfigSrc -PathType Leaf)) {
    $mcpConfigContent = Get-Content -LiteralPath $mcpConfigSrc -Raw -Encoding UTF8
    if ($mcpConfigContent -notmatch '__HOME_REPO__') {
        throw "MCP 設定缺少 __HOME_REPO__ 路徑權杖：$mcpConfigSrc"
    }
    $resolvedHomeRepo = [IO.Path]::GetFullPath($homeRepo).Replace('\', '/')
    $mcpConfigContent = $mcpConfigContent.Replace('__HOME_REPO__', $resolvedHomeRepo)
    $items += @{ Source = $mcpConfigSrc; Target = Join-Path $antigravityHome 'mcp_config.json'; Content = $mcpConfigContent }
}
$items += $skillPlan.Items
$availableConfigSkillDirs = Get-ChildItem -LiteralPath (Join-Path $homeRepo 'configs\skills') -Directory -ErrorAction SilentlyContinue
$availableRootSkillDirs = Get-ChildItem -LiteralPath (Join-Path $homeRepo 'skills') -Directory -ErrorAction SilentlyContinue
$allSkillDirs = @($availableConfigSkillDirs) + @($availableRootSkillDirs)
foreach ($dir in $allSkillDirs) {
    if (-not $skillPlan.Assigned.ContainsKey($dir.Name)) {
        Write-Warning "發現未分流的 Skill 目錄 [$($dir.Name)]，未包含於 configs\skills-manifest.json 中。"
    }
}
foreach ($item in $items) {
    $content = if ($item.ContainsKey('Content')) { $item['Content'] } else { $null }
    Sync-ManagedItem $item.Source $item.Target $old $new $content
}

if (-not $CheckOnly -and $PruneBackups) {
    $backupBase = Join-Path $codexHome 'bridge-backups'
    if (Test-Path -LiteralPath $backupBase) {
        $oldBackups = Get-ChildItem -LiteralPath $backupBase -Directory | Sort-Object CreationTime -Descending | Select-Object -Skip 10
        foreach ($oldBackup in $oldBackups) {
            Remove-Item -LiteralPath $oldBackup.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if (-not $CheckOnly) {
    $result = [ordered]@{
        schemaVersion = 1
        source = $homeRepo
        generatedAt = (Get-Date).ToString('o')
        excluded = @{
            codexStandaloneSkills = '.codex\skills is preserved for individual local Skills and is not overwritten by this shared deployment.'
            codexSystemSkills = '.codex\skills\.system is managed by Codex and is never overwritten.'
            routing = 'configs\skills-manifest.json controls shared, Codex-only, and Antigravity-only Skill deployment. Shared Skills are also deployed to .claude\skills.'
        }
        items = @($new.Keys | Sort-Object | ForEach-Object { [ordered]@{ target = $_; hash = $new[$_] } })
    }
    $json = $result | ConvertTo-Json -Depth 5
    [System.IO.File]::WriteAllText($manifestPath, $json, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Manifest: $manifestPath"
}
