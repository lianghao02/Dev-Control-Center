# 機敏資料與路徑安全檢核清單 (Sensitive Data Checklist)

提交或交接前必須確認：
- [ ] 1. 無任何 API Key、Token、私鑰、密碼出現在檔案中。
- [ ] 2. 無硬編碼之本機個人絕對路徑（如 `C:\Users\<使用者名稱>\...` 或固定磁碟代號）。
- [ ] 3. 本機設定檔（如 `%USERPROFILE%\.lianghao\config.json`）已正確被 `.gitignore` 排除或留在外層。
- [ ] 4. 未提交任何非必要的大型二進位測試暫存檔或日誌檔案。
