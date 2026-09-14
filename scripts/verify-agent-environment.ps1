# UTF-8 Compatibility
[CmdletBinding()]
param(
    [switch]$Detailed
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  LiangHao Agent 環境驗證 (verify-agent-environment)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

$resolverScript = Join-Path $PSScriptRoot 'skill-resolver.ps1'
if (-not (Test-Path -LiteralPath $resolverScript -PathType Leaf)) {
    throw "找不到 Skill 解析器：$resolverScript"
}

$report = [ordered]@{
    SkillHome = $null
    Version = $null
    ResolutionSource = $null
    ResolverPass = $false
    CanonicalFilesPass = $false
    AntigravityReferencePass = $false
    CodexReferencePass = $false
    AutomaticSkillDeployment = 'NOT VERIFIED'
    CheckDetails = @()
}

# 1. 驗證 Resolver
try {
    $res = & $resolverScript -Detailed
    if ($res.Status -eq 'FOUND' -and (Test-Path -LiteralPath $res.SkillHome)) {
        $report.SkillHome = $res.SkillHome
        $report.Version = $res.Version
        $report.ResolutionSource = $res.Source
        $report.ResolverPass = $true
        $report.CheckDetails += "[PASS] Resolver 成功解析 Skill: $($res.SkillHome) (來源: $($res.Source), 版本: $($res.Version))"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Green
    } else {
        $report.CheckDetails += "[FAIL] Resolver 無法找到 Skill"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Red
    }
} catch {
    $report.CheckDetails += "[FAIL] Resolver 執行異常: $($_.Exception.Message)"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Red
}

# 2. 驗證 Canonical Skill 核心結構
if ($report.ResolverPass) {
    $requiredFiles = @(
        'VERSION',
        'SKILL.md',
        'references\project-governance.md',
        'references\agent-execution.md',
        'references\release-policy.md',
        'references\project-product-assessment.md',
        'references\windows-development.md',
        'references\data-safety.md',
        'workflows\audit-project.md',
        'workflows\evaluate-project.md',
        'workflows\fix-project.md',
        'workflows\improve-project.md',
        'workflows\release-project.md',
        'workflows\handoff-project.md',
        'templates\agent-task.md',
        'templates\handoff.md',
        'templates\project-scorecard.md',
        'templates\release-report.md',
        'checklists\baseline.md',
        'checklists\post-change.md',
        'checklists\release-gate.md',
        'checklists\sensitive-data.md',
        'examples\sample-handoff.md'
    )

    $missing = @()
    foreach ($rf in $requiredFiles) {
        $p = Join-Path $report.SkillHome $rf
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) {
            $missing += $rf
        }
    }

    if ($missing.Count -eq 0) {
        $report.CanonicalFilesPass = $true
        $report.CheckDetails += "[PASS] Canonical 結構檢驗完整 (共 $($requiredFiles.Count) 項標準檔案/目錄就緒)"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Green
    } else {
        $report.CheckDetails += "[FAIL] Canonical 結構缺少檔案: $($missing -join ', ')"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Red
    }
}

# 3. 驗證 Pilot 的引用規則
if ($report.ResolverPass) {
    $report.AntigravityReferencePass = $true
    $report.CheckDetails += "[PASS] Antigravity 可透過共用 Resolver 取得 Canonical Skill（僅驗證引用規則）"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Green
}

if ($report.ResolverPass) {
    $report.CodexReferencePass = $true
    $report.CheckDetails += "[PASS] Codex 可透過共用 Resolver 取得 Canonical Skill（僅驗證引用規則）"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Green
}

# 4. 驗證平台原生自動載入部署與 Hash 一致性
$codexSkillPath = Join-Path $env:USERPROFILE '.agents\skills\lianghao-development'
$antiSkillPath = Join-Path $env:USERPROFILE '.gemini\config\skills\lianghao-development'

function Get-TreeHashForVerify([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $records = Get-ChildItem -LiteralPath $Path -File -Recurse -Force |
        Sort-Object FullName |
        ForEach-Object {
            $relative = $_.FullName.Substring($Path.Length).TrimStart('\')
            '{0}|{1}' -f $relative, (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes(($records -join "`n")))
    try { return (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash }
    finally { $stream.Dispose() }
}

$codexExists = Test-Path -LiteralPath (Join-Path $codexSkillPath 'SKILL.md')
$antiExists = Test-Path -LiteralPath (Join-Path $antiSkillPath 'SKILL.md')

if ($codexExists -and $antiExists -and $report.ResolverPass) {
    $canonicalHash = Get-TreeHashForVerify $report.SkillHome
    $codexHash = Get-TreeHashForVerify $codexSkillPath
    $antiHash = Get-TreeHashForVerify $antiSkillPath

    $vCodex = if (Test-Path -LiteralPath (Join-Path $codexSkillPath 'VERSION')) { (Get-Content (Join-Path $codexSkillPath 'VERSION') -Raw).Trim() } else { $null }
    $vAnti = if (Test-Path -LiteralPath (Join-Path $antiSkillPath 'VERSION')) { (Get-Content (Join-Path $antiSkillPath 'VERSION') -Raw).Trim() } else { $null }

    if ($canonicalHash -eq $codexHash -and $canonicalHash -eq $antiHash -and $vCodex -eq $report.Version -and $vAnti -eq $report.Version) {
        $report.AutomaticSkillDeployment = 'PASS'
        $report.CheckDetails += "[PASS] 平台原生自動部署驗證通過 (Codex & Antigravity 目錄就緒、Version=$($report.Version)、TreeHash 完全一致)"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Green
    } else {
        $report.AutomaticSkillDeployment = 'FAIL'
        $report.CheckDetails += "[FAIL] 平台原生自動部署 Hash 或版本不一致 (Canonical: $canonicalHash, Codex: $codexHash, Anti: $antiHash)"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Red
    }
} else {
    $report.AutomaticSkillDeployment = 'FAIL'
    $report.CheckDetails += "[FAIL] 平台原生自動部署目標目錄未就緒 (Codex: $codexExists, Anti: $antiExists)"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Red
}

$allPass = $report.ResolverPass -and $report.CanonicalFilesPass -and $report.AntigravityReferencePass -and $report.CodexReferencePass -and ($report.AutomaticSkillDeployment -eq 'PASS')

Write-Host "-----------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "驗證總結：$(if ($allPass) { '全數通過 (ALL PASS)' } else { '未完全通過' })" -ForegroundColor $(if ($allPass) { 'Green' } else { 'Red' })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($Detailed) {
    return [PSCustomObject]$report
}

if (-not $allPass) {
    exit 1
}
