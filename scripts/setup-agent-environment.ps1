# UTF-8 Compatibility
[CmdletBinding()]
param(
    [string]$WorkspaceRoot = '',
    [string]$ConfigPath = '',
    [switch]$SetUserEnv,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

# 透過 $PSScriptRoot 動態鎖定 Dev-Control-Center，絕不依賴目前工作目錄
$controlCenterPath = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath (Join-Path $controlCenterPath 'skills\lianghao-development'))) {
    throw "無法由腳本位置判定控制中心與 Canonical Skill 目錄：$controlCenterPath"
}
$controlCenterPath = [IO.Path]::GetFullPath($controlCenterPath)
$canonicalSkillHome = [IO.Path]::GetFullPath((Join-Path $controlCenterPath 'skills\lianghao-development'))

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  LiangHao Agent 環境設置 (setup-agent-environment)" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Canonical Skill 來源: $canonicalSkillHome" -ForegroundColor Gray
Write-Host "Dev-Control-Center:   $controlCenterPath" -ForegroundColor Gray

# 1. 決定本機設定檔位置；測試可傳入暫存檔，避免寫入真實使用者設定。
$configFile = if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    Join-Path $env:USERPROFILE '.lianghao\config.json'
} else {
    [IO.Path]::GetFullPath($ConfigPath)
}
$configDir = Split-Path -Parent $configFile
if (-not (Test-Path -LiteralPath $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "已建立本機設定目錄: $configDir" -ForegroundColor Green
}

$configData = [ordered]@{
    '$schema' = 'https://json-schema.org/draft/2020-12/schema'
    description = 'LiangHao 本機 Agent 環境配置（本機專屬，不入 Git）'
    skillHome = $canonicalSkillHome
    controlCenterPath = $controlCenterPath
    workspaceRoots = @()
    agentPreferences = [ordered]@{
        defaultTaskType = 'AUDIT'
        strictHandoff = $true
    }
}

# 若已有設定檔，安全合併既有設定，絕不破壞
if (Test-Path -LiteralPath $configFile -PathType Leaf) {
    try {
        $existing = Get-Content -LiteralPath $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $managedProperties = @('$schema', 'description', 'skillHome', 'controlCenterPath', 'workspaceRoots', 'agentPreferences')
        foreach ($prop in $existing.PSObject.Properties) {
            if ($managedProperties -notcontains $prop.Name) {
                $configData[$prop.Name] = $prop.Value
            }
        }
        if ($existing.PSObject.Properties['workspaceRoots']) {
            $configData.workspaceRoots = @($existing.workspaceRoots)
        }
        if ($existing.PSObject.Properties['agentPreferences']) {
            foreach ($prop in $existing.agentPreferences.PSObject.Properties) {
                $configData.agentPreferences[$prop.Name] = $prop.Value
            }
        }
        Write-Host "已繼承既有本機設定 ($configFile)" -ForegroundColor Gray
    } catch {
        Write-Warning "讀取既有設定檔失敗，將重整覆蓋: $($_.Exception.Message)"
    }
}

# 判斷是否注入 WorkspaceRoot
if (-not [string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $resolvedWorkspace = [IO.Path]::GetFullPath($WorkspaceRoot)
    if ($configData.workspaceRoots -notcontains $resolvedWorkspace) {
        $configData.workspaceRoots += $resolvedWorkspace
    }
} else {
    # 預設探索父層目錄
    $parentWorkspace = Split-Path -Parent $controlCenterPath
    if ($configData.workspaceRoots.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($parentWorkspace) -and (Test-Path -LiteralPath $parentWorkspace)) {
        $configData.workspaceRoots += [IO.Path]::GetFullPath($parentWorkspace)
    }
}

# 寫入設定檔（無 BOM UTF-8）
$jsonContent = $configData | ConvertTo-Json -Depth 5
[IO.File]::WriteAllText($configFile, $jsonContent, [Text.UTF8Encoding]::new($false))
Write-Host "已更新本機配置: $configFile" -ForegroundColor Green

# 2. 若指定 -SetUserEnv，寫入 User scope 環境變數 LIANGHAO_SKILL_HOME
if ($SetUserEnv) {
    [Environment]::SetEnvironmentVariable('LIANGHAO_SKILL_HOME', $canonicalSkillHome, [EnvironmentVariableTarget]::User)
    $env:LIANGHAO_SKILL_HOME = $canonicalSkillHome
    Write-Host "已設定使用者環境變數 LIANGHAO_SKILL_HOME = $canonicalSkillHome" -ForegroundColor Green
}

Write-Host "環境設定完成。重複執行安全且冪等。" -ForegroundColor Cyan
