# Portable 免安裝發布驗收檢核清單 (Portable Release Checklist)

- [ ] 1. 解壓縮後雙擊直接開啟，無需預先安裝 Python、Node 或 .NET SDK。
- [ ] 2. 測試純乾淨 Windows 虛擬機或非開發機，無缺少 VC++ Redistributable 或 DLL 報錯。
- [ ] 3. 程式目錄路徑含中文與空白時，仍可正常啟動與保存設定。
- [ ] 4. 軟體更新時覆寫執行檔，既有使用者設定與輸出資料不被清除。
