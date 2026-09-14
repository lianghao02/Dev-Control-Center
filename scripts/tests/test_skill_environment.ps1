# UTF-8 Compatibility
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$homeRepo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$resolverScript = Join-Path $homeRepo 'scripts\skill-resolver.ps1'
$setupScript = Join-Path $homeRepo 'scripts\setup-agent-environment.ps1'
$verifyScript = Join-Path $homeRepo 'scripts\verify-agent-environment.ps1'
$canonicalSkill = Join-Path $homeRepo 'skills\lianghao-development'

$passCount = 0
$failCount = 0

function Report-Check([string]$Name, [bool]$Condition, [string]$Message) {
    if ($Condition) {
        $script:passCount++
        Write-Host "  [PASS] $Name : $Message" -ForegroundColor Green
    } else {
        $script:failCount++
        Write-Host "  [FAIL] $Name : $Message" -ForegroundColor Red
    }
}

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  LiangHao Skill & Environment 自動化測試套件" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# 測試 1: Resolver - Workspace Discovery (由控制中心出發)
$res1 = & $resolverScript -Detailed
$t1Pass = ($res1.Status -eq 'FOUND' -and (Test-Path -LiteralPath $res1.SkillHome) -and $res1.Version -eq '1.0.0')
Report-Check "1. Resolver 預設/工作區解析測試" $t1Pass "成功解析 SkillHome=$($res1.SkillHome), Version=$($res1.Version), Source=$($res1.Source)"

# 測試 2: Resolver - 環境變數優先級覆寫測試
$fakeTempRoot = Join-Path ([IO.Path]::GetTempPath()) ("fake-skill-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fakeTempRoot -Force | Out-Null
Set-Content -Path (Join-Path $fakeTempRoot 'VERSION') -Value '9.9.9' -Encoding utf8NoBOM

$oldEnv = $env:LIANGHAO_SKILL_HOME
try {
    $env:LIANGHAO_SKILL_HOME = $fakeTempRoot
    $res2 = & $resolverScript -Detailed
    $t2Pass = ($res2.Status -eq 'FOUND' -and $res2.SkillHome -eq [IO.Path]::GetFullPath($fakeTempRoot) -and $res2.Version -eq '9.9.9' -and $res2.Source -match 'EnvironmentVariable')
    Report-Check "2. Resolver 環境變數優先級測試" $t2Pass "成功由環境變數優先覆寫 (Version: $($res2.Version))"
} finally {
    $env:LIANGHAO_SKILL_HOME = $oldEnv
    Remove-Item -LiteralPath $fakeTempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

# 測試 3: Resolver - 模擬可攜性路徑 (Portable Path 模擬：非原磁碟/非固定路徑)
$portableWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("portable-ws-" + [Guid]::NewGuid().ToString('N'))
$portableDevCenter = Join-Path $portableWorkspace '00_Dev-Control-Center'
$portableSkill = Join-Path $portableDevCenter 'skills\lianghao-development'
$portableRepo = Join-Path $portableWorkspace '09_PaperSwitch'
$portableScripts = Join-Path $portableDevCenter 'scripts'
New-Item -ItemType Directory -Path $portableSkill, $portableRepo, $portableScripts -Force | Out-Null
Set-Content -Path (Join-Path $portableSkill 'VERSION') -Value '1.0.0' -Encoding utf8NoBOM
Copy-Item -LiteralPath $resolverScript -Destination (Join-Path $portableScripts 'skill-resolver.ps1') -Force

$oldEnv3 = $env:LIANGHAO_SKILL_HOME
try {
    $env:LIANGHAO_SKILL_HOME = $null
    # 從外部專案 09_PaperSwitch 出發，指定 TargetRepository，測試探索
    $res3 = & (Join-Path $portableDevCenter 'scripts\skill-resolver.ps1') -TargetRepository $portableRepo -IgnoreUserConfig -Detailed
    $t3Pass = ($res3.Status -eq 'FOUND' -and $res3.SkillHome -eq [IO.Path]::GetFullPath($portableSkill))
    Report-Check "3. 可攜性動態探索測試 (非原磁碟模擬)" $t3Pass "成功從獨立 Worktree/Repo 鄰近探索到 Skill: $($res3.SkillHome)"
} finally {
    $env:LIANGHAO_SKILL_HOME = $oldEnv3
    Remove-Item -LiteralPath $portableWorkspace -Recurse -Force -ErrorAction SilentlyContinue
}

# 測試 4: Resolver - 找不到時明確回報 NOT FOUND
$emptyTemp = Join-Path ([IO.Path]::GetTempPath()) ("empty-temp-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $emptyTemp -Force | Out-Null
$oldEnv4 = $env:LIANGHAO_SKILL_HOME
try {
    $env:LIANGHAO_SKILL_HOME = $null
    # 在空目錄下呼叫 resolver（無任何鄰近 skill，並忽略 UserConfig）
    $isolatedScript = Join-Path $emptyTemp 'resolver.ps1'
    Copy-Item -LiteralPath $resolverScript -Destination $isolatedScript -Force
    
    $caughtError = $false
    try {
        & $isolatedScript -TargetRepository $emptyTemp -IgnoreUserConfig -ErrorAction Stop | Out-Null
    } catch {
        $caughtError = $true
    }

    $res4Detailed = & $isolatedScript -TargetRepository $emptyTemp -IgnoreUserConfig -Detailed
    $t4Pass = ($caughtError -and $res4Detailed.Status -eq 'NOT FOUND')
    Report-Check "4. 找不到 Skill 時安全錯誤回報測試" $t4Pass "正確拋錯或回傳 Status='NOT FOUND'"
} finally {
    $env:LIANGHAO_SKILL_HOME = $oldEnv4
    Remove-Item -LiteralPath $emptyTemp -Recurse -Force -ErrorAction SilentlyContinue
}

# 測試 5: Setup 冪等性與安全合併測試
$tempConfigDir = Join-Path ([IO.Path]::GetTempPath()) (".lianghao-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempConfigDir -Force | Out-Null
try {
    $testConfigFile = Join-Path $tempConfigDir 'config.json'
    $testWorkspace = Join-Path $tempConfigDir 'workspace'
    New-Item -ItemType Directory -Path $testWorkspace -Force | Out-Null
    [ordered]@{
        customSetting = 'keep-me'
        agentPreferences = [ordered]@{ customPreference = 'keep-me' }
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $testConfigFile -Encoding utf8NoBOM

    # 執行 setup
    & $setupScript -WorkspaceRoot $testWorkspace -ConfigPath $testConfigFile | Out-Null
    $cfg1 = Get-Content -LiteralPath $testConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $hasSkillHome1 = ($cfg1.skillHome -eq [IO.Path]::GetFullPath($canonicalSkill))
    
    # 重複執行 setup
    & $setupScript -WorkspaceRoot $testWorkspace -ConfigPath $testConfigFile | Out-Null
    $cfg2 = Get-Content -LiteralPath $testConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $hasSkillHome2 = ($cfg2.skillHome -eq [IO.Path]::GetFullPath($canonicalSkill))

    $keepsCustomSettings = ($cfg1.customSetting -eq 'keep-me' -and $cfg2.customSetting -eq 'keep-me' -and $cfg2.agentPreferences.customPreference -eq 'keep-me')
    Report-Check "5. Setup 冪等性與安全合併測試" ($hasSkillHome1 -and $hasSkillHome2 -and $keepsCustomSettings) "重複執行設定不破壞既有資料結構與自訂欄位"
} finally {
    Remove-Item -LiteralPath $tempConfigDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 測試 6: Verify-Agent-Environment 驗收腳本測試
$verifyRes = & $verifyScript -Detailed
$t6Pass = ($verifyRes.ResolverPass -and $verifyRes.CanonicalFilesPass -and $verifyRes.AntigravityReferencePass -and $verifyRes.CodexReferencePass -and $verifyRes.AutomaticSkillDeployment -eq 'PASS')
Report-Check "6. 全環境驗收驗證腳本測試" $t6Pass "verify-agent-environment.ps1 回報全數通過 (含平台原生自動部署 PASS)"

# 測試 7: 跨 Agent Handoff 解析與跨平台元資料完整性
$sampleHandoff = Join-Path $canonicalSkill 'examples\sample-handoff.md'
$handoffContent = Get-Content -LiteralPath $sampleHandoff -Raw -Encoding UTF8
$hasRepoName = ($handoffContent -match 'Repository.*?lianghao02/')
$hasBranch = ($handoffContent -match 'Branch.*?main')
$hasCommit = ($handoffContent -match 'Commit SHA.*?[a-f0-9]{7,}')
$hasSkillVersion = ($handoffContent -match 'Skill Version.*?v1\.0\.0')
$hasTaskType = ($handoffContent -match 'Task Type.*?(AUDIT|EVALUATE|FIX|IMPROVE|RELEASE|HANDOFF)')
$t7Pass = ($hasRepoName -and $hasBranch -and $hasCommit -and $hasSkillVersion -and $hasTaskType)
Report-Check "7. 跨 Agent Handoff 標準元資料驗證" $t7Pass "示範 Handoff 具備 Repo/Branch/Commit/SkillVersion/TaskType 五大關鍵標識"

# 測試 8: 平台原生自動載入目錄與 Hash 一致性校驗
# 測試 8: 平台原生自動載入目錄與 Hash 一致性校驗 (四大共用 Skill)
$allSharedSkills = @(
    'lianghao-development',
    'taiwan-office-automation',
    'safe-data-processing',
    'windows-tool-ux'
)
$allSkillsPass = $true
$skillsCheckedCount = 0

foreach ($sk in $allSharedSkills) {
    $canDir = Join-Path $homeRepo "skills\$sk"
    $cSkillDir = Join-Path $env:USERPROFILE ".agents\skills\$sk"
    $aSkillDir = Join-Path $env:USERPROFILE ".gemini\config\skills\$sk"
    $cFile = Join-Path $cSkillDir 'SKILL.md'
    $aFile = Join-Path $aSkillDir 'SKILL.md'
    
    if ((Test-Path -LiteralPath $cFile) -and (Test-Path -LiteralPath $aFile)) {
        $cVer = (Get-Content -LiteralPath (Join-Path $canDir 'VERSION') -Raw).Trim()
        $codexVer = (Get-Content -LiteralPath (Join-Path $cSkillDir 'VERSION') -Raw).Trim()
        $antiVer = (Get-Content -LiteralPath (Join-Path $aSkillDir 'VERSION') -Raw).Trim()

        $canHash = (Get-FileHash -LiteralPath (Join-Path $canDir 'SKILL.md') -Algorithm SHA256).Hash
        $codexHash = (Get-FileHash -LiteralPath $cFile -Algorithm SHA256).Hash
        $antiHash = (Get-FileHash -LiteralPath $aFile -Algorithm SHA256).Hash

        if ($cVer -eq '1.0.0' -and $codexVer -eq '1.0.0' -and $antiVer -eq '1.0.0' -and $canHash -eq $codexHash -and $canHash -eq $antiHash) {
            $skillsCheckedCount++
        } else {
            $allSkillsPass = $false
        }
    } else {
        $allSkillsPass = $false
    }
}
$t8Pass = ($allSkillsPass -and $skillsCheckedCount -eq 4)
Report-Check "8. 雙平台原生 Skill 目錄存在性與版本一致性" $t8Pass "四大共用 Skill 皆完整部署至 Codex 與 Antigravity，且 VERSION/Hash 完全一致"

Write-Host "-----------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "測試結果統計：通過 $passCount / 失敗 $failCount (共 $($passCount + $failCount) 項)" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($failCount -gt 0) {
    exit 1
}
