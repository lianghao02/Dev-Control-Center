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
$canonicalSkill = Join-Path $homeRepo 'configs\skills\lianghao-development'

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
$fakeSkillHome = Join-Path $fakeTempRoot 'configs\skills\lianghao-development'
New-Item -ItemType Directory -Path $fakeSkillHome -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $fakeSkillHome 'VERSION'), '9.9.9', [Text.UTF8Encoding]::new($false))

$oldEnv = $env:LIANGHAO_SKILL_HOME
try {
    $env:LIANGHAO_SKILL_HOME = $fakeSkillHome
    $res2 = & $resolverScript -Detailed
    $t2Pass = ($res2.Status -eq 'FOUND' -and $res2.SkillHome -eq [IO.Path]::GetFullPath($fakeSkillHome) -and $res2.Version -eq '9.9.9' -and $res2.Source -match 'EnvironmentVariable')
    Report-Check "2. Resolver 環境變數優先級測試" $t2Pass "成功由環境變數優先覆寫 (Version: $($res2.Version))"
} finally {
    $env:LIANGHAO_SKILL_HOME = $oldEnv
    Remove-Item -LiteralPath $fakeTempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

# 測試 3: Resolver - 模擬可攜性路徑 (Portable Path 模擬：非原磁碟/非固定路徑)
$portableWorkspace = Join-Path ([IO.Path]::GetTempPath()) ("portable-ws-" + [Guid]::NewGuid().ToString('N'))
$portableDevCenter = Join-Path $portableWorkspace '00_Dev-Control-Center'
$portableSkill = Join-Path $portableDevCenter 'configs\skills\lianghao-development'
$portableRepo = Join-Path $portableWorkspace '09_PaperSwitch'
$portableScripts = Join-Path $portableDevCenter 'scripts'
New-Item -ItemType Directory -Path $portableSkill, $portableRepo, $portableScripts -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $portableSkill 'VERSION'), '1.0.0', [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath $resolverScript -Destination (Join-Path $portableScripts 'skill-resolver.ps1') -Force

$oldEnv3 = $env:LIANGHAO_SKILL_HOME
try {
    $env:LIANGHAO_SKILL_HOME = $null
    # 從外部專案 09_PaperSwitch 出發，指定 TargetRepository，測試探索
    $res3 = & (Join-Path $portableDevCenter 'scripts\skill-resolver.ps1') -TargetRepository $portableRepo -IgnoreUserConfig -Detailed
    $t3Pass = ($res3.Status -eq 'FOUND' -and $res3.SkillHome -eq [IO.Path]::GetFullPath($portableSkill) -and $res3.ControlCenterPath -eq [IO.Path]::GetFullPath($portableDevCenter))
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
    $initJson = ([ordered]@{
        customSetting = 'keep-me'
        agentPreferences = [ordered]@{ customPreference = 'keep-me' }
    } | ConvertTo-Json -Depth 3)
    [IO.File]::WriteAllText($testConfigFile, $initJson, [Text.UTF8Encoding]::new($false))

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

# 測試 6、8：在隔離的暫存設定檔中檢查實際同步與漏檔偵測。
$tempProfile = Join-Path ([IO.Path]::GetTempPath()) ("skill-profile-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempProfile -Force | Out-Null
$oldProfile = $env:USERPROFILE
try {
    $env:USERPROFILE = $tempProfile
    $syncScript = Join-Path $homeRepo 'scripts\sync_codex.ps1'
    & $syncScript -CheckOnly -SkipMcpConfig | Out-Null
    $previewReadOnly = @(Get-ChildItem -LiteralPath $tempProfile -Force).Count -eq 0
    & $syncScript -Execute -SkipMcpConfig | Out-Null

    $verifyRes = & $verifyScript -Detailed
    $manifest = Get-Content -LiteralPath (Join-Path $homeRepo 'configs\skills-manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $expectedTargets = 3 * @($manifest.shared).Count + @($manifest.codexOnly).Count + @($manifest.antigravityOnly).Count
    $t6Pass = ($previewReadOnly -and $verifyRes.ResolverPass -and $verifyRes.CanonicalFilesPass -and
        $verifyRes.AntigravityReferencePass -and $verifyRes.CodexReferencePass -and
        $verifyRes.AutomaticSkillDeployment -eq 'PASS' -and $verifyRes.DeploymentTargetsChecked -eq $expectedTargets)
    Report-Check "6. 全環境驗收驗證腳本測試" $t6Pass "預覽唯讀，完整比對 $expectedTargets 個部署目標"

    $agyOnly = Join-Path $tempProfile '.gemini\config\skills\skill-creator\SKILL.md'
    $codexOnly = Join-Path $tempProfile '.agents\skills\skill-creator'
    $claudeOnly = Join-Path $tempProfile '.claude\skills\skill-creator'
    $routesCorrect = ((Test-Path -LiteralPath $agyOnly -PathType Leaf) -and
        -not (Test-Path -LiteralPath $codexOnly) -and -not (Test-Path -LiteralPath $claudeOnly))

    $removedEntry = Join-Path $tempProfile '.agents\skills\product-design\SKILL.md'
    $staleReference = Join-Path $tempProfile '.gemini\config\skills\product-design\references\ui-review.md'
    Remove-Item -LiteralPath $removedEntry
    Add-Content -LiteralPath $staleReference -Value 'isolated stale content' -Encoding UTF8
    $broken = & $verifyScript -Detailed
    $t8Pass = ($routesCorrect -and $broken.AutomaticSkillDeployment -eq 'FAIL' -and
        ($broken.CheckDetails -match 'Codex / product-design.*缺少 SKILL.md') -and
        ($broken.CheckDetails -match 'Antigravity / product-design.*內容與中央來源不同'))
} finally {
    $env:USERPROFILE = $oldProfile
    Remove-Item -LiteralPath $tempProfile -Recurse -Force -ErrorAction SilentlyContinue
}

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

# 測試 8：只部署到目標平台，並能找出遺失入口及過期參考檔。
Report-Check "8. Skill 分流與部署漏檔偵測" $t8Pass "AGY 專用 Skill 分流正確，遺失 SKILL.md 及過期參考檔皆回報失敗"

Write-Host "-----------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "測試結果統計：通過 $passCount / 失敗 $failCount (共 $($passCount + $failCount) 項)" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "=================================================================" -ForegroundColor Cyan

if ($failCount -gt 0) {
    exit 1
}
