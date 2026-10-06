# 版本發布政策與交付標準 (Release Policy)

## 1. 語意化版本號 (Semantic Versioning)
- 遵循 `vMajor.Minor.Patch` 格式。
- Patch：Bug 修復、相容性微調、文檔修正。
- Minor：新增向後相容的功能、流程優化。
- Major：不相容之架構升級、重大功能重構。

## 2. 發布檢核道門 (Release Gates)
- **Gate 1: Git 潔淨度**：Working Tree 乾淨，無未追蹤臨時檔，分支無分歧。
- **Gate 2: 自動化測試**：核心測試套件 100% 通過。
- **Gate 3: 本機實測／Build 驗收**：桌面 App 成功產生免安裝套件，執行檔可啟動無崩潰。
- **Gate 4: 文檔更新**：更新 `CHANGELOG.md` 與版本標記，文案符合台灣繁體中文規範。
- **Gate 5: 機敏資料防禦**：無 Token、本機絕對路徑硬編碼。
