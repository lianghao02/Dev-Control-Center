# 免安裝工具產品架構規範 (Portable Design)

## 1. 綠色免安裝 (Portable) 定義
- 應用程式解壓縮至任意目錄（包括 USB 隨身碟、公務機 D 槽或桌面），點擊即可執行。
- 嚴禁要求使用者先安裝 Python、Node.js、Java 或 .NET SDK（.NET 專案應採用 Self-contained / Native AOT 發布；Python 專案應以 PyInstaller / Nuitka 封裝或隨附輕量內嵌 Runtime）。

## 2. 應用程式與資料分離
- **二進位主體 (Binaries)**：可隨時替換更新，程式本身保持無狀態（Stateless）。
- **使用者設定與輸出 (User Data)**：
  - Portable 模式：預設儲存於同級之 `data/` 或 `config.json`。
  - 更新版本時，直接覆寫執行檔不得影響或重設既有的設定檔。
