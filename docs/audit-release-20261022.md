# 2026-10-22 修訂內容與發布結果

使用者已授權分專案提交、推送與發布。19 排除；本輪沒有改全域設定或 Skills。

## 版本與提交

| 專案 | 版本 | 提交 | 發布 |
|---|---|---|---|
| 12_ClipMask-AI | v1.1.1 | [aba03b9](https://github.com/lianghao02/ClipMask-AI/commit/aba03b943c4be38f8571bdf864277c3f3d4193c3) | [Release](https://github.com/lianghao02/ClipMask-AI/releases/tag/v1.1.1) |
| 08_Financial-Data-Parser | v1.8.1 | [f9d85b7](https://github.com/lianghao02/Financial-Data-Parser/commit/f9d85b70c3adbb1a3a2bf2bb1fd3b3461148fd33) | [Release](https://github.com/lianghao02/Financial-Data-Parser/releases/tag/v1.8.1) |
| 02_Cell-Tower-Map-Locator | v3.2.4 | [2713489](https://github.com/lianghao02/Cell-Tower-Map-Locator/commit/2713489304d0e89bf5a526b1aed12c8760d2beef) | [Release](https://github.com/lianghao02/Cell-Tower-Map-Locator/releases/tag/v3.2.4) |
| 11_Calendar-Card-App | v1.3.1 | [4ff8486](https://github.com/lianghao02/Calendar-Card-App/commit/4ff84865affbc1cbcdbab339341820c90cfab594) | [Release](https://github.com/lianghao02/Calendar-Card-App/releases/tag/v1.3.1) |
| 17_Subscription-Manager | v1.2.1 | [1aa2831](https://github.com/lianghao02/Subscription-Manager/commit/1aa2831a60f81507abe3e6aa3b84a593026a3456) | [Release](https://github.com/lianghao02/Subscription-Manager/releases/tag/v1.2.1) |
| 18_AromaCraft-Studio | v1.6.5 | [46fb453](https://github.com/lianghao02/AromaCraft-Studio/commit/46fb4531623cff8c2f35d5af4259d7150058abdc) | [Release](https://github.com/lianghao02/AromaCraft-Studio/releases/tag/v1.6.5) |
| 14_Google-Photos-Takeout-Organizer | v1.3.1 | [ed58c54](https://github.com/lianghao02/14_Google-Photos-Takeout-Organizer/commit/ed58c54a05d272738c194e67a339a2187d8609a8) | [Release](https://github.com/lianghao02/14_Google-Photos-Takeout-Organizer/releases/tag/v1.3.1) |
| 03_Police-Image-Toolkit | 不升版，僅文件 | [db433e1](https://github.com/lianghao02/Police-Image-Toolkit/commit/db433e1c16c9ce209345150943f3af788604d7d5) | 已推送 |
| 13_Project-Hub | 同步七筆版本 | [a67518c](https://github.com/lianghao02/Project-Hub/commit/a67518c5bff76b0577cea82ba637d1d43018e71f) | Pages 已部署、3/3 檔一致 |

## 具體修訂

### 12：保護來源與既有輸出

- `clipmask/export/exporter.py`：以解析後路徑與同檔檢查拒絕來源同一路徑／硬連結。先寫同資料夾暫存檔，成功後才以 `os.replace` 替換目標；取消、編碼與進度回報失敗時清理暫存，保留既有輸出。透過 `ExitStack` 關閉影音資源，避免失敗後持續占用檔案。
- `tests/test_export_safety.py`：補來源保護、硬連結、取消保留舊輸出、失敗清理、成功替換及完成回報失敗案例；修正前先重現 4 項失敗。
- `clipmask.spec`：發布驗收發現 PATH 中 Poppler 的 `icuuc.dll` 被選入成品，造成 QtWidgets 載入失敗；將 DLL 搜尋限制在 Python 與 Windows 標準路徑，重建後不再包含該錯誤 ICU。
- 完整測試 **55/55**。正式免安裝成品從中文空白路徑、不同工作目錄與隔離 Python 環境變數啟動，正常主視窗標題為「ClipMask-AI — 智慧影音去識別化手帳工作站」，顯示後存活 8 秒、正常關閉、exit code 0。這不代表已人工檢視全部畫面或功能。

### 08：修正真正的離線 Worker 啟動

- `js/app.js`：移除四層錯誤／連外 `importScripts` 備援，把本機 XLSX 原文直接組入 Blob Worker；資源缺失時明確回報。
- `js/libs/xlsx.worker-source.js` 與 `scripts/build-worker-source.cjs`：由既有 `xlsx.bundle.js` 產生可由傳統 script 載入的原始碼字串，保留原套件授權；建置與檢查統一換行。執行工具不需要 Node.js。
- `index.html` 改載入 Worker 資源；`tests/harness.js` 改走正式 Blob 組合並禁止網路載入，不再預先注入 XLSX 掩蓋啟動失敗。更新 npm test、QA 與打包預設版本。
- 改正載入器後原版 17 項全敗；修復後 **17/17**。正式網址真瀏覽器實際上傳虛構 CSV、完成下載，讀回長帳號 `0012345678901234567` 與文字格式 `@` 完整，金額 `1234` 正確，主控台錯誤／警告 0。
- `file://` 雙擊離線包仍受瀏覽器工具政策限制而未驗證，沒有繞過限制。

### 02、11、17、18：隔離同來源快取

- 分別修改 `sw.js`（17 為 `public/sw.js`）：啟用時僅刪除屬於本專案前綴、且非目前版本的快取；保留其他專案快取。
- 新增 `tests/service-worker.test.*`，以實際 activate 處理器及多專案快取名稱重現誤刪，修正前四項全敗，修正後各專案完整測試 **31／22／27／99 項全數通過**。
- 02 更新快取至 `cell-tower-locator-v3`；11 為 Build 39／`calendar-card-app-v5`；17 為 `subscription-manager-v1.2.1`；18 為 `aromacraft-v1.6.5`。
- 18 用既有產生器重建 `index.html`，沒有手改 Client 或雲端資料。GitHub Release v1.6.5 也承接此前已在主線與網站上的 v1.6.3／v1.6.4，完整歷史見 CHANGELOG。
- 11／17 只部署 Firebase Hosting，沒有部署 Firestore 規則或寫入使用者資料。

### 14：將既有修補正式發版

- 承接既有 `e21f691` 的跨 ZIP 成對、整組檔名衝突與 ZIP 修改時間保底修正，本輪未重新實作這些演算法。
- `__init__.py`／`pyproject.toml` 升 v1.3.1；`service.py` 與 `report.py` 引用程式版本，保留歷史 manifest 的原版本，新增兩項版本一致性測試。
- 更正 README 舊的「尚未提交修補」描述；補上 Windows 深層路徑安裝可能超限的說明與啟動失敗指引，未改系統設定。
- 原開發環境與中文空白短路徑的新建環境均 **33/33**；CLI `gpto 1.3.1`、pip check、Windows PowerShell 5.1 從專案外執行 `-NoLaunch` 通過。
- 以原始碼 ZIP 發布，維持 Python 3.13+／RUN.bat 模式，首次安裝需要網路，不是獨立 EXE。舊 manifest 與解壓快取不會自動更正，請從來源 ZIP 在新工作目錄重新分析。

### 03：消除測試指令矛盾

- `AGENTS.md` 第 4 節統一為 `scripts/test.ps1`；既有腳本實際使用 `dotnet run` 執行自訂主控台測試。
- 保留「dotnet test 可能結束碼 0 卻未執行任何案例」的警示。只改文件，不另升版，也不以這輪文件修改宣稱重跑 .NET 測試。

### 13 與交接

- 僅更新七筆已發布產品的 version，再以 `sync_projects.py --mode fallback` 同步備援資料；16 筆資料檢查通過。其他欄位、圖片、CSS 與 19 的物件內容均不變。
- 各專案共用 HANDOFF 已記錄修正、驗證與人工缺口；中央計畫與唯一改善總表統一收尾，不新增個人交接檔。

## 部署驗證

- 11_Calendar-Card-App/dist/pages：21/21 檔與部署包或 Git 提交位元組一致（https://calendar-family-lianghao02.web.app）。
- 17_Subscription-Manager/dist：33/33 檔與部署包或 Git 提交位元組一致（https://subscription-ledger-f77fd.web.app）。
- 02_Cell-Tower-Map-Locator：5/5 檔與部署包或 Git 提交位元組一致（https://lianghao02.github.io/Cell-Tower-Map-Locator/）。
- 08_Financial-Data-Parser：6/6 檔與部署包或 Git 提交位元組一致（https://lianghao02.github.io/Financial-Data-Parser/）。
- 18_AromaCraft-Studio：2/2 檔與部署包或 Git 提交位元組一致（https://lianghao02.github.io/AromaCraft-Studio/）。

Pages 核對以 Git 提交的原始位元組為準；Windows 工作目錄的 CRLF 不直接拿來冒充 Git 內的 LF。Firebase 則核對實際部署包，包含依既有流程注入的公開網頁設定。

- 13_Project-Hub：3/3（首頁、JSON、備援 JavaScript）與提交 a67518c 一致，七筆版本已正式上線。

## 發布附件

| 檔案 | bytes | SHA-256 |
|---|---:|---|
| ClipMask-AI-v1.1.1-Portable.zip | 137248580 | `e987b10d80ab41d7bea797160b82488b5e59bbf05cd67051ef645652fba702c9` |
| Financial-Data-Parser-v1.8.1.zip | 346451 | `6eaa91143730b323d13859fddbd0eb1b59e984794ca1b925fc76646450a00d3f` |
| Google-Photos-Takeout-Organizer-v1.3.1-source.zip | 1370653 | `7b149233b3245538673191ada57b4affb66a2c7caab11e7bb03fd257ea1bbb14` |

12／08／14 三份正式附件均已下載回驗，SHA-256 與本機一致；12 的 GitHub digest 亦一致。

## 保留的驗收限制

- 08 的 file:// 雙擊離線包、真實手機已安裝 PWA 更新、不同電腦與非管理者環境尚未實測。
- 12 已驗證程式啟動／正常主視窗標題／正常關閉，未擷取整個桌面，也未人工檢查全部畫面。
- 14 有 Windows 深層路徑安裝限制；原生 GUI 人工操作、真正雙擊 RUN.bat 與真人 Takeout 未重驗。
- 11／17 的登入、家庭／帳號同步與 Firestore 規則沒有在此輪重新操作或部署。
- 19、07 大拆與 16 分支合併不在本輪範圍。

## 完整修訂檔

各專案 `.patch` 已匯出至中央 `artifacts/release-20261022/`，最終另提供修訂差異 ZIP。包含私人專案的完整差異僅留在本機被忽略的 artifacts，不上傳公開展示站。

## 最終交付狀態

七個產品與 03／13 共九個倉庫，工作目錄 Clean、追蹤分支 0/0；七個 annotated tag 均指向本輪產品提交。中央由包含本報告的提交推送收尾，最終以 Git 為準。

完整修訂差異：本機 artifacts/release-20261022/修訂差異-20261022.zip。包含十個目標倉庫的 patch、修訂說明、發布資料與 SHA256SUMS；私人專案差異不公開上傳。
