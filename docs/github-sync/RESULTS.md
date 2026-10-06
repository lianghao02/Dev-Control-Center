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

16 個成果提交均已正常推送至既有 origin；以 `git ls-remote` 核對遠端分支 SHA 全數一致。DesktopFramesPlus 原有 3 筆領先提交亦已同步。推送後 15 個工作目錄 Clean，07 僅保留原有兩個修改；05 仍完整保留本機成果，沒有提交或推送。

下表記錄成果提交；中央報告與交接的收尾提交另行正常推送，最新中央 HEAD 以 Git 記錄為準，避免在文件內產生 SHA 自我引用。

| Repository | 分支 | 成果提交 | 遠端核對 | 推送後工作目錄 |
|---|---|---|---|---|
| 00_Dev-Control-Center | main | [089ca715](https://github.com/lianghao02/Dev-Control-Center/commit/089ca715964a49f127f5781c094f70c7ebb900b9) | SHA 一致 | Clean |
| 01_AG-MONITOR-Smart-Video-Screening | main | [e8713b12](https://github.com/lianghao02/AG-MONITOR-Smart-Video-Screening/commit/e8713b12800459fb219f8fcba79a992ad9123be6) | SHA 一致 | Clean |
| 02_Cell-Tower-Map-Locator | main | [9e58b6e8](https://github.com/lianghao02/Cell-Tower-Map-Locator/commit/9e58b6e84cf9be2332ee2523026b32d6282b054c) | SHA 一致 | Clean |
| 03_Police-Image-Toolkit | main | [561b5a31](https://github.com/lianghao02/Police-Image-Toolkit/commit/561b5a314ffc49d2eff0101e18a7785f95460c29) | SHA 一致 | Clean |
| 04_Photo-Report-Generator | main | [720137f5](https://github.com/lianghao02/Photo-Report-Generator/commit/720137f5b32f5e91e6c3a8a5a738c6b021253e16) | SHA 一致 | Clean |
| 06_System-Optimizer-Tool | main | [3aa7cc27](https://github.com/lianghao02/System-Optimizer-Tool/commit/3aa7cc274bf8b43cc0fede0f864d33a07e646f42) | SHA 一致 | Clean |
| 07_auto-learning-bot | main | [6d672f9b](https://github.com/lianghao02/auto-learning-bot/commit/6d672f9b04a6b2413cac1d26bff71bd9ef67672a) | SHA 一致 | 保留原有 2 個修改 |
| 08_Financial-Data-Parser | main | [6232169c](https://github.com/lianghao02/Financial-Data-Parser/commit/6232169c5d5155538e33302c611a249e66f10069) | SHA 一致 | Clean |
| 09_PaperSwitch | main | [e2f49bf0](https://github.com/lianghao02/PaperSwitch/commit/e2f49bf0d55cd75260dedffd320d3d65831d6ac1) | SHA 一致 | Clean |
| 10_Smart-Photo-Organizer | main | [605dafd6](https://github.com/lianghao02/Smart-Photo-Organizer/commit/605dafd645c4543d78e5a188131e7a87798751f6) | SHA 一致 | Clean |
| 11_Calendar-Card-App | main | [316f8c11](https://github.com/lianghao02/Calendar-Card-App/commit/316f8c1114fa71653df15ec4126d68a0cf1635f9) | SHA 一致 | Clean |
| 12_ClipMask-AI | master | [b334b5fa](https://github.com/lianghao02/ClipMask-AI/commit/b334b5faa01122f04adcdf10f27b0259a29639b5) | SHA 一致 | Clean |
| 13_Project-Hub | main | [45f9656e](https://github.com/lianghao02/Project-Hub/commit/45f9656e0fef8fd43140ff1863997b14954a6919) | SHA 一致 | Clean |
| 14_Google-Photos-Takeout-Organizer | main | [16011cde](https://github.com/lianghao02/14_Google-Photos-Takeout-Organizer/commit/16011cde913b8b09978f501461dda5c21ad6e829) | SHA 一致 | Clean |
| 15_chainflow-inspector | main | [1faa2a26](https://github.com/lianghao02/chainflow-inspector/commit/1faa2a260a6971a37136bece902c44e198eaadae) | SHA 一致 | Clean |
| DesktopFramesPlus | main | [18986575](https://github.com/lianghao02/DesktopFramesPlus/commit/18986575a1267e34104d39e8e6388a9a71ffe206) | SHA 一致 | Clean |

### 10 的 Linux QA 補修

10 的初始成果提交為 `1a74647e9f668530e1984ea345f2ad78e384008c`。首次 [Linux QA](https://github.com/lianghao02/Smart-Photo-Organizer/actions/runs/37402744083) 執行 148 項，因既有 QuickTime 日期測試固定預期台灣時間，實際 UTC 主機相差 8 小時而失敗（1 失敗、8 略過）；產品按本機時區轉換的行為正確。只修改測試與 AGENTS／HANDOFF，產品 `main.py` SHA-256 不變，沒有更動系統時區或依賴。

追加 `605dafd645c4543d78e5a188131e7a87798751f6` 修正預期值並加入 UTC／UTC+8／UTC−5 三組測試，且校準既有 unittest 入口。本機受影響 18 項：17 通過、1 略過；[最新 Linux QA](https://github.com/lianghao02/Smart-Photo-Organizer/actions/runs/37403422741) 完整 149 項：141 通過、8 略過，多時區測試通過。原始失敗保留於此，不改寫成通過。

收尾工具首次拆解遠端 SHA 的方式有誤，重查直接比較後確認補修已成功推送、SHA 完全一致；這是本機記錄工具問題，未修改產品或採用 force push。



### GitHub Actions

以下查詢均限定本輪實際提交 SHA；無執行紀錄不代表執行過測試。已觸發工作全部完成，沒有將排隊或進行中列為通過。

| Repository | 工作／紀錄 | 結果 |
|---|---|---|
| 00_Dev-Control-Center | 此提交無新 Actions 執行紀錄 | — |
| 01_AG-MONITOR-Smart-Video-Screening | 此提交無新 Actions 執行紀錄 | — |
| 02_Cell-Tower-Map-Locator | [pages-build-deployment](https://github.com/lianghao02/Cell-Tower-Map-Locator/actions/runs/37402532624) | success |
| 03_Police-Image-Toolkit | [pages-build-deployment](https://github.com/lianghao02/Police-Image-Toolkit/actions/runs/37402606700) | success |
| 04_Photo-Report-Generator | [pages-build-deployment](https://github.com/lianghao02/Photo-Report-Generator/actions/runs/37402607871) | success |
| 06_System-Optimizer-Tool | 此提交無新 Actions 執行紀錄 | — |
| 07_auto-learning-bot | 此提交無新 Actions 執行紀錄 | — |
| 08_Financial-Data-Parser | [pages-build-deployment](https://github.com/lianghao02/Financial-Data-Parser/actions/runs/37402673012) | success |
| 09_PaperSwitch | [CI 自動化建置與測試](https://github.com/lianghao02/PaperSwitch/actions/runs/37402673829) | success |
| 09_PaperSwitch | [pages-build-deployment](https://github.com/lianghao02/PaperSwitch/actions/runs/37402672762) | success |
| 10_Smart-Photo-Organizer | [共用 QA](https://github.com/lianghao02/Smart-Photo-Organizer/actions/runs/37403422741) | success |
| 10_Smart-Photo-Organizer | [pages-build-deployment](https://github.com/lianghao02/Smart-Photo-Organizer/actions/runs/37403421830) | success |
| 11_Calendar-Card-App | [pages-build-deployment](https://github.com/lianghao02/Calendar-Card-App/actions/runs/37402742500) | success |
| 12_ClipMask-AI | 此提交無新 Actions 執行紀錄 | — |
| 13_Project-Hub | [Deploy GitHub Pages](https://github.com/lianghao02/Project-Hub/actions/runs/37402806401) | success |
| 14_Google-Photos-Takeout-Organizer | 此提交無新 Actions 執行紀錄 | — |
| 15_chainflow-inspector | 此提交無新 Actions 執行紀錄 | — |
| DesktopFramesPlus | 此提交無新 Actions 執行紀錄 | — |

### 保護與交付邊界

05 的 7 個成果檔案、07 的兩個原有修改共 9 個檔案 SHA-256 不變；10 本機 runtime 1,011／1,011 個檔案仍在。沒有 Commit／Push 05，也沒有重新加入依賴包、成品、備份或使用者資料。本輪完成的是原始碼與文件同步，沒有建立正式 Release。

本機細部證據保存於 Git 忽略的 `artifacts/github-sync-2ff41adbcb3a4a1ab091c0a98e67bc77/`；此目錄不隨 Repository 發布。
