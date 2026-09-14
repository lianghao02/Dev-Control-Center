# Windows 10/11 相容性與邊界規範 (Windows Compatibility)

## 1. 執行環境標準情境
- **作業系統**：主要鎖定 **Windows 10 (21H2+) 與 Windows 11**。不可僅針對 Win11 設計而導致 Win10 缺少 API 崩潰。
- **使用者名稱與路徑防衛**：
  - 常見使用者資料夾含中文字元（如 `C:\Users\陳大文\...`）或空白（如 `C:\Program Files\...`）。
  - 所有呼叫子行程、外部執行檔（FFmpeg、Git）或讀寫檔案，路徑一律使用引號完整包覆或使用不受 Code Page 影響之 API（如 `Path.Combine`, `Path(__file__)`）。
- **非管理員權限 (Non-Admin)**：
  - 公務電腦通常無本機 Administrator 權限。
  - 應用程式嚴禁寫入 `C:\Windows\` 或 `C:\Program Files\`，亦不可強制要求 UAC 提權才能執行主功能。所有快取與本機設定應置於 `%LOCALAPPDATA%` 或工具同級目錄。
