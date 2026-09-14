# 疑義檔案隔離處置範例 (Examples: Quarantine Handling)

```powershell
function Quarantine-File {
    param(
        [string]$FilePath,
        [string]$QuarantineDirectory,
        [string]$Reason
    )

    if (-not (Test-Path -LiteralPath $FilePath)) { return }

    New-Item -ItemType Directory -Path $QuarantineDirectory -Force | Out-Null
    $fileName = Split-Path -Leaf $FilePath
    $targetPath = Join-Path $QuarantineDirectory $fileName

    Move-Item -LiteralPath $FilePath -Destination $targetPath -Force

    $manifest = Join-Path $QuarantineDirectory 'quarantine_manifest.jsonl'
    $logEntry = [ordered]@{
        timestamp = (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')
        originalPath = $FilePath
        quarantinePath = $targetPath
        reason = $Reason
    } | ConvertTo-Json -Compress

    Add-Content -LiteralPath $manifest -Value $logEntry -Encoding utf8NoBOM
}
```
