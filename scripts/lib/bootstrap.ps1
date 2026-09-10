# 共用主控台與解譯器初始化；相容 PowerShell 7 與 Windows PowerShell 5.1。
try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
} catch {
    Write-Warning "無法設定 UTF-8 主控台編碼：$($_.Exception.Message)"
}

function Get-HomePowerShell {
    $powerShell7 = Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($powerShell7) {
        return $powerShell7.Source
    }
    return 'powershell.exe'
}

function Get-HomeDevelopmentRoot([string]$HomeRepository) {
    $parent = Split-Path -Parent $HomeRepository
    if ([string]::IsNullOrWhiteSpace($parent)) {
        throw "無法從 home 專案路徑判斷開發根目錄：$HomeRepository"
    }

    # 控制中心位於「00\_Dev-Control-Center」時，00 是分類目錄；
    # 開發根目錄仍是其上一層，與其他 Repository 同層。
    if ((Split-Path -Leaf $parent) -eq '00') {
        $parent = Split-Path -Parent $parent
        if ([string]::IsNullOrWhiteSpace($parent)) {
            throw "無法從 home 專案路徑判斷開發根目錄：$HomeRepository"
        }
    }

    return [IO.Path]::GetFullPath($parent)
}

function Get-RepositoryVersion([string]$RepoPath) {
    if (-not (Test-Path -LiteralPath $RepoPath)) {
        return '未存在'
    }

    $candidateFiles = @(
        (Join-Path $RepoPath 'version.txt'),
        (Join-Path $RepoPath 'src\PoliceImageToolkit\version.txt'),
        (Join-Path $RepoPath 'dotnet-src\version.txt')
    )

    foreach ($f in $candidateFiles) {
        if (Test-Path -LiteralPath $f -PathType Leaf) {
            try {
                $raw = (Get-Content -LiteralPath $f -Encoding UTF8 -TotalCount 1).Trim()
                if ($raw -match '^[vV]?\d+(\.\d+)+') {
                    return $raw
                }
            } catch {}
        }
    }

    return '未標註'
}
