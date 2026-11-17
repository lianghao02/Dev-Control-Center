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

. (Join-Path $PSScriptRoot 'lib\skill-deployment.ps1')

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
    DeploymentTargetsChecked = 0
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
        'references\python-environments.md',
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

# 4. 依部署分流清單逐一比對受管 Skill 的整個目錄。
try {
    $plan = Get-SkillDeploymentPlan (Split-Path -Parent $PSScriptRoot) $env:USERPROFILE
    if ($plan.Items.Count -eq 0) { throw 'Skill 分流清單沒有任何部署目標。' }
    $sourceHashes = @{}
    $report.AutomaticSkillDeployment = 'PASS'
    foreach ($item in $plan.Items) {
        $label = "$($item.Platform) / $($item.Name)"
        $sourceFile = Join-Path $item.Source 'SKILL.md'
        $targetFile = Join-Path $item.Target 'SKILL.md'
        $report.DeploymentTargetsChecked++
        $problem = if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            "中央來源缺少 SKILL.md：$sourceFile"
        } elseif (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) {
            "部署目標缺少 SKILL.md：$targetFile"
        } else {
            if (-not $sourceHashes.ContainsKey($item.Source)) {
                $sourceHashes[$item.Source] = Get-TreeHash $item.Source
            }
            if ($sourceHashes[$item.Source] -ne (Get-TreeHash $item.Target)) {
                "部署目錄內容與中央來源不同：$($item.Target)"
            }
        }
        if ($problem) {
            $report.AutomaticSkillDeployment = 'FAIL'
            $report.CheckDetails += "[FAIL] ${label}：$problem"
            Write-Host $report.CheckDetails[-1] -ForegroundColor Red
        }
    }

    # 解析器可能指向另一份工作區，需核對其核心 Skill 與部署來源一致。
    $canonical = Join-Path (Split-Path -Parent $PSScriptRoot) 'configs\skills\lianghao-development'
    if ($report.ResolverPass -and $sourceHashes.ContainsKey($canonical) -and
        $report.SkillHome -ne $canonical -and (Get-TreeHash $report.SkillHome) -ne $sourceHashes[$canonical]) {
        $report.AutomaticSkillDeployment = 'FAIL'
        $report.CheckDetails += "[FAIL] Resolver 選取的 lianghao-development 與中央部署來源內容不同：$($report.SkillHome)"
        Write-Host $report.CheckDetails[-1] -ForegroundColor Red
    }
} catch {
    $report.AutomaticSkillDeployment = 'FAIL'
    $report.CheckDetails += "[FAIL] Skill 部署檢查無法完成：$($_.Exception.Message)"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Red
}
if ($report.AutomaticSkillDeployment -eq 'PASS') {
    $report.CheckDetails += "[PASS] $($report.DeploymentTargetsChecked) 個 Skill 部署目標與中央來源一致"
    Write-Host $report.CheckDetails[-1] -ForegroundColor Green
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
