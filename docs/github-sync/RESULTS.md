# 2026-10-06 GitHub 同步與交付檢核

本輪依使用者「如果沒有問題，就同步到 GitHub」授權整理前輪成果。同步 16 個 Repository；`05_tw-formal-writing` 的 origin 無法存取，依使用者明確回覆略過，保留本機成果與既有 remote。尚未建立正式 Release。

## 提交邊界

- 只提交前輪已授權環境修復、目錄整理、README、入口與功能修復，以及本輪必要的編碼修正與交接。
- `07_auto-learning-bot/ui.py`、`utils/app_paths.py` 原有修改不提交，原始 SHA-256 逐一核對。
- 10 的 1,011 個 embedded runtime 檔案只自 Git 索引解除追蹤，本機檔案保留，不重新加入版本庫。
- 全域 Python、PATH、全域套件、使用者原始資料、現行執行中的 DesktopFramesPlus、正式 ZIP 與系統文件保護沒有變更。
- 所有分支與 origin 經核對；其餘遠端沒有較新的提交。DesktopFramesPlus 原已領先 3 筆既有提交，一併正常推送，不採用 force push。

## 本輪發現與必要修正

16 個 PowerShell 腳本原為無 BOM 的 UTF-8，PowerShell 5.1 會誤讀中文並造成語法失敗。本輪僅加入 UTF-8 BOM，確認每份檔案除 BOM 外的位元組完全一致。29 個候選腳本於 PowerShell 5.1／7 的語法檢查全部通過；01／07／10／12／15 環境入口與中央 Skill CheckOnly 在 5.1 實際執行亦通過。VBS 維持既有 UTF-16 編碼。

## 已執行驗證

| 範圍 | 本輪結果 |
|---|---|
| 10 正式測試入口 | 148 項：147 通過、1 略過 |
| 07 提交來源隔離快照 | 70 項全部通過；原有兩個修改使用 HEAD 版本測試 |
| Python 環境邊界 | 5 項通過 |
| 共用 Skill／環境規則 | 8 項通過；中央同步 CheckOnly 通過 |
| PaperSwitch 入口 | 5.1／7 各 8 項，共 16 項通過 |
| DesktopFramesPlus 入口 | 5.1／7 各 7 項，共 14 項通過 |
| DesktopFramesPlus 繁中資源 | 674 個基準鍵覆蓋通過 |
| 06 現行原生成品入口 | ValidateOnly 通過 |
| 敏感資料、差異、語法 | 包含新增 JSON 報告的全文檢查；Git diff --check；Python AST、JSON、TOML、XML 與 PowerShell 檢核通過 |

10 首次誤用 pytest 入口時因未安裝 pytest 失敗，後改用專案既有 unittest 入口，不安裝額外套件。首次入口測試的主機參數錯配亦已改正後重跑；上述數字為成功重跑的真實結果。

前輪代表性功能、成品套用及使用者資料雜湊證據繼承 [成品驗收](../new-build-acceptance/RESULTS.md)、[修復結果](../remaining-fixes/RESULTS.md)，沒有宣稱本輪重測未受影響的所有功能。

## 尚待處理與限制

- PaperSwitch 的 Office 正常轉 PDF 仍受 IGEF 環境限制；必須使用單位核准的標準 PDF 產出／讀取流程後再驗收，保留產品拒絕防護。詳見 [IGEF 診斷](../new-build-acceptance/IGEF-DIAGNOSIS.md)。
- 05 本輪不提交或推送；07 的兩個原有修改仍留在本機。
- 乾淨電腦、跨路徑／Win10、真人素材、線上採集與正式重新打包屬後續驗收；全域套件去重另案處理。

## 已核對的提交計畫

| Repository | 分支 | 提交訊息 |
|---|---|---|
| 00_Dev-Control-Center | main | chore: 收斂共用技能來源與環境治理並補齊驗收報告 |
| 01_AG-MONITOR-Smart-Video-Screening | main | fix: 隔離 embedded 使用者套件並鎖定開發環境 |
| 02_Cell-Tower-Map-Locator | main | docs: 補齊專案概念、開發原因與已知限制 |
| 03_Police-Image-Toolkit | main | docs: 補齊專案概念、開發原因與已知限制 |
| 04_Photo-Report-Generator | main | chore: 更新專案說明並清理舊測試資料 |
| 06_System-Optimizer-Tool | main | chore: 將發布成品路由集中至 dist 並更新文件 |
| 07_auto-learning-bot | main | fix: 隔離 embedded 啟動與建置環境 |
| 08_Financial-Data-Parser | main | docs: 補齊專案概念、開發原因與已知限制 |
| 09_PaperSwitch | main | fix: 修正成品入口判定並記錄 Office 加密限制 |
| 10_Smart-Photo-Organizer | main | fix: 限制 Shell 等待並隔離專案 Python 環境 |
| 11_Calendar-Card-App | main | docs: 補齊專案概念、開發原因與已知限制 |
| 12_ClipMask-AI | master | fix: 隔離開發環境並整理驗收文件 |
| 13_Project-Hub | main | docs: 補齊專案概念、開發原因與已知限制 |
| 14_Google-Photos-Takeout-Organizer | main | docs: 更新專案說明並整理匯出文件 |
| 15_chainflow-inspector | main | fix: 統一專案 Python 入口並鎖定相依套件 |
| DesktopFramesPlus | main | fix: 校準版本與發布防護並補齊功能驗收 |

## 遠端結果

提交與推送尚待執行；完成後於本節補上實際 SHA、遠端核對及 CI 結果，不能把提交前檢核視為已同步。

本機細部證據保存於 Git 忽略的 `artifacts/github-sync-2ff41adbcb3a4a1ab091c0a98e67bc77/`；此目錄不隨 Repository 發布。
