# UTF-8 Compatibility
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

function Get-SkillDeploymentPlan([string]$RepositoryRoot, [string]$UserProfile) {
    $manifestPath = Join-Path $RepositoryRoot 'configs\skills-manifest.json'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw "找不到 Skill 分流清單：$manifestPath"
    }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($manifest.schemaVersion -ne 2) {
        throw "不支援的 Skill 分流版本：$($manifest.schemaVersion)"
    }
    $roots = [ordered]@{
        'Codex' = Join-Path $UserProfile '.agents\skills'
        'Antigravity' = Join-Path $UserProfile '.gemini\config\skills'
        'Claude Code' = Join-Path $UserProfile '.claude\skills'
    }
    $groups = @(
        @{ Name = '共用'; Skills = @($manifest.shared); Platforms = @($roots.Keys) },
        @{ Name = 'Codex 專用'; Skills = @($manifest.codexOnly); Platforms = @('Codex') },
        @{ Name = 'Antigravity 專用'; Skills = @($manifest.antigravityOnly); Platforms = @('Antigravity') }
    )
    $assigned = @{}
    $items = foreach ($group in $groups) {
        foreach ($name in $group.Skills) {
            if ($name -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
                throw "無效的 Skill 名稱：$name"
            }
            if ($assigned.ContainsKey($name)) {
                throw "Skill [$name] 同時出現在 [$($assigned[$name])] 與 [$($group.Name)]，請只保留一個分流類別。"
            }
            $assigned[$name] = $group.Name
            $source = Join-Path $RepositoryRoot "configs\skills\$name"
            foreach ($platform in $group.Platforms) {
                @{ Name = $name; Platform = $platform; Source = $source; Target = Join-Path $roots[$platform] $name }
            }
        }
    }
    return @{ Roots = $roots; Assigned = $assigned; Items = @($items) }
}

function Get-TreeHash([string]$Path) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    }
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
