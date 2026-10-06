# Portable 免安裝發行包相容性審驗流程 (Review Portable Release Workflow)

1. **乾淨虛擬機/隔離目錄測試**：
   - 將 Portable ZIP 解壓縮至未安裝任何開發環境、使用者名稱含中文且路徑含空白之測試資料夾。
2. **免安裝點擊驗收**：
   - 雙擊執行檔，確認無跳出缺少 DLL、缺少 Python、缺少 .NET 執行階段錯誤。
3. **資料持久性驗收**：
   - 修改軟體設定並儲存，確認設定寫入同級 `config.json` 或 `%LOCALAPPDATA%`。
   - 模擬軟體升級覆寫執行檔，確認既有設定完好無損。
