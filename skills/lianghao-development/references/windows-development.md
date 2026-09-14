# Windows 原生開發與腳本標準 (Windows Development)

## 1. 路徑強健性與動態探索
- 嚴禁硬編碼固定磁碟（`C:\`、`D:\`）或本機個人路徑（`%USERPROFILE%` 硬編碼）。
- PowerShell 一律使用 `$PSScriptRoot` 與 `Join-Path` 動態取得相對路徑。
- BAT 批次檔一律使用 `%~dp0`，並正確處理中文路徑與引號包裹。

## 2. 薄啟動器原則 (Thin Launcher)
- 根目錄 BAT 僅負責：固定工作目錄、探索 PowerShell 執行檔、以無干擾參數傳遞給 `.ps1`、必要時暫停。
- 所有邏輯運算、外部命令呼叫與錯誤處理均由 PowerShell 承擔。

## 3. 編碼防衛
- 腳本開頭一律強制設定 UTF-8 主控台編碼與全域輸出編碼。
- 文字檔案讀寫一律明確指定無 BOM 的 UTF-8。
- 二進位檔案（圖片、模型、音訊、PDF、Excel）嚴禁套用文字編碼參數。
