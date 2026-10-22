> 修復階段歷史快照：本輪後續已獲使用者授權提交發布，實際結果見 [修訂內容與發布結果](audit-release-20261022.md)。以下「尚未提交／發布」描述僅代表準備階段。

# 2026-10-22 跨專案已確認缺陷修復

本輪為本機修正與候選包準備，尚未提交、推送、部署或建立 Release。19 排除；前輪已完成拆分與部署成果繼承。

## 修正與驗證

| 專案 | 已修正內容 | 證據 |
|---|---|---|
| 12 | 來源同檔／硬連結防護、暫存輸出、成功後替換、失敗關閉資源 | 新增案例先重現 4 項失敗；最終完整 pytest 55/55，含可解碼影音、音軌、取消、例外、成功替換與來源不變 |
| 08 | 本機 XLSX 程式直接組入 Blob Worker，移除 importScripts 與 CDN 備援 | 修正載入器後原版 17 項全敗；修復後 17/17、PowerShell 5.1 QA／語法通過；HTTP 子目錄真瀏覽器轉檔與下載內容核對，console 錯誤／警告 0 |
| 02 | Service Worker 啟用只清理自己的舊快取 | 原版隔離測試失敗；完整 npm test 31/31 |
| 11 | 同上 | 原版隔離測試失敗；完整 npm test 22/22，含 JS 語法檢查 |
| 17 | 同上 | 原版隔離測試失敗；完整 npm test 27/27 |
| 18 | 同上 | 原版隔離測試失敗；完整 npm test 99/99；測試產生的 index.html 時間戳已還原 |
| 03 | AGENTS 第 4 節改用 scripts/test.ps1 | 核對腳本實際使用 dotnet run；移除錯誤執行指令。純文件變更，未重跑 .NET |
| 14 | 準備 v1.3.1 修補候選版，manifest／報告引用程式版本 | 原開發環境 pytest 33/33；31 檔候選 ZIP 解壓後與原始碼逐檔相符。全新環境安裝、pytest 33/33、CLI、pip check 與 5.1 啟動器 -NoLaunch 通過 |

08 的長帳號測試完全使用虛構 CSV；下載的 synthetic.xlsx 中 B2 為文字 0012345678901234567，格式 @，C2 為 1234。生成的 Worker 套件保留原套件授權與原始 xlsx.bundle.js，以 scripts/build-worker-source.cjs 重建；npm test／QA 檢查資源同步並統一換行。

快取測試直接執行正式 sw.js 的 activate 處理器，同時提供四專案、目前版本與不相關前綴的快取名稱，確認只刪本專案舊版。11 的本機資料損毀測試會刻意印出警告／錯誤；測試通過不代表沒有這些預期記錄。

## 14 候選包

- 既有修正 e21f691 承接，未重新實作成對媒體與 ZIP 日期邏輯。
- 版本為 v1.3.1，CHANGELOG 明確標為尚未發布；README 更正「修正尚未提交」的舊描述。
- 輸出為原始碼 ZIP，維持 RUN.bat＋Python 3.13+；首次安裝相依套件需要網路。未執行已廢止的 PyInstaller build_windows.ps1。
- 候選包：artifacts/audit-fixes/Google-Photos-Takeout-Organizer-v1.3.1-source.zip，1,370,738 bytes。
- SHA-256：dc9763750ab5dbc4819dcace65840d660522a757775aca49136eeacb8aa934e8。
- 31 檔清單與雜湊：artifacts/audit-fixes/14-package-manifest.json、SHA256SUMS.txt。產物與環境被 .gitignore 排除。
- 通過驗證的中文空白路徑：artifacts/驗 收/14。
- 乾淨環境：全新 .venv 安裝 requirements.txt 成功，33/33 測試通過；CLI 回報 gpto 1.3.1，pip check 無問題，從專案外以 Windows PowerShell 5.1 執行啟動器 -NoLaunch 通過。PySide6 6.12.0、Pillow 13.0.0、pillow-heif 1.8.1。
- 深層路徑安裝曾因 Windows 長路徑限制失敗，已記錄並補上 README／啟動失敗處置提示；未變更登錄或系統設定。這不代表所有長路徑都可用。

## 未完成的驗收與發布邊界

- 瀏覽器工具安全政策拒絕 file://；08 雙擊離線包仍待人工驗收。未以其他瀏覽器表面繞過政策，HTTP／vm 證據不冒充 file:// 實測。
- 原生 GUI 人工操作、真實手機已安裝 PWA 更新、跨電腦驗收未執行；14 自動化測試只處理合成媒體，未接觸真人 Takeout。
- 11／17 Firebase 登入、規則及雲端資料均未修改或重驗；18 的 Client／建置來源未變。
- 來源修正不會自動更新正式站與舊下載包。發布需另經使用者授權，14 發布後再同步 13 展示版本。
- 本輪新增與修改範圍及基準，以各專案 HANDOFF 與 Git Diff 為準；不將其他工作階段成果混入本輪提交。
