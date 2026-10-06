# 發布前道門檢核清單 (Release Gate Checklist)

正式建立發行版或推送 Release 前必須確認：
- [ ] 1. Working Tree 處於完全乾淨 (Clean) 狀態。
- [ ] 2. 所有核心自動化測試 100% 通過。
- [ ] 3. 桌面應用程式或發行套件已完成本機執行驗收（可秒開無報錯）。
- [ ] 4. 跨電腦或 Portable 發行已完成 Fresh Environment 驗收：Repository 換位置、非原開發磁碟、不同 Windows 使用者名稱及含中文或空白路徑可啟動；不依賴 IDE、未記錄的全域套件或殘留環境變數；Portable 版不要求安裝開發環境；Runtime／相依缺失時提供明確處置訊息。
- [ ] 5. `CHANGELOG.md` 已完整記載版本里程碑與功能亮點。
- [ ] 6. 專案版本號標註正確對齊。
- [ ] 7. 無敏感資料、本機個人路徑硬編碼。
