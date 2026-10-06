# 逐專案目錄配置與清理結果

> 後續修復（2026-10-05）：本文保留整理當時的驗證結果；09 PaperSwitch 入口已完成修復與重新建置，兩種 PowerShell 入口及主視窗啟動通過，見 [入口修復報告](../paperswitch-launch-repair/RESULTS.md)。

2026-10-05；範圍為 GitHub 工作區的 17 個 Repository。承接前輪 Python 環境修復；本輪由同一主責 Agent 執行，未提交或推送。

## 配置判斷

依入口、匯入、建置、離線資產及資料安全邊界決定配置。已合理的目錄保留；不為統一名稱而搬動環境、模型、靜態頁面或 upstream 原始碼。

| 專案 | 採用配置 | 已執行整理 | 保留與原因 |
|---|---|---|---|
| 00 Dev-Control-Center | `configs/` 正式設定與 Skills；`scripts/` 工具；`docs/` 報告；`artifacts/test-runs/` 未來測試產物 | 合併 `config` 設定範例至 `configs`；清掉前輪合成素材、空的 objects/refs/skills/config | 下載的 embedded 安裝 ZIP供離線設定；鎖定中的 cases.db 保留 |
| 01 AG-MONITOR | 維持根目錄 Python 入口、trackers/web/tests/docs；captures 為使用者資料 | 清除入口及 tests 位元碼快取 | 五份 YOLO 模型、captures、embedded 及現行 v4.0.1 發行包；避免破壞模型查找與 Portable |
| 02 Cell-Tower | 維持 index/css/js/docs/scripts 靜態站 | 無必要搬移或刪除 | 靜態網址與離線資源位置維持 |
| 03 Police-Image-Toolkit | 維持 src/tests/scripts 與根目錄 dist | 無必要搬移或刪除 | 現行 EXE、指南與版本資訊；Release 建置資產保持 |
| 04 Photo-Report | 維持 Web/Tauri、vendor、tests/fixtures、tests/baseline | 刪除 4 張未被現行測試引用的舊 test_photos；更新 README | 現行 fixtures、Golden Baseline、vendor、web 與 node_modules；既有測試全部通過 |
| 05 tw-formal-writing | 維持規範、references/examples/scripts/docs 與根目錄 CLI 輔助工具 | 清除 scripts 位元碼快取 | STANDALONE/LITE、.venv-pdf、現行發行包；既有 CLI 呼叫不變 |
| 06 System-Optimizer | dotnet-src 保存 src/tests；根目錄 scripts 保存入口；根目錄 dist 保存發行 | publish 整包移至 dist，11 個檔案逐檔雜湊一致；更新 BAT、PS、中央工具及文件；清除 Debug 產物 | standalone/slim 與現行 v6.2.3 成品；legacy-python 歷史備援完整保留，僅更新其正式入口指引 |
| 07 auto-learning | 維持根目錄 Python 入口、models/utils、drivers、data 與 embedded | 清除快取 | 使用者設定、答案、題庫及 WAL/SHM、Chrome driver；既有 ui.py/app_paths.py 修改完全保留；本輪基準 dist 已為空，未宣稱刪除歷史 runtime |
| 08 Financial-Data | 維持 css/js/libs/scripts/docs 純 Web | 無必要搬移或刪除 | 離線 libs 與現行 v1.7.1 發行包 |
| 09 PaperSwitch | 維持 dotnet-src/src/tests/scripts、dist/publish、dist/release_assets | 刪除 v4.0.0/4.1.0/4.1.2/4.2.0/4.2.1 的清冊列示舊成品、舊 SHA 清單、Debug 及測試傾印 | 現行 v4.3.0 EXE、SHA、release_notes、Release 啟動候選與 publish 既有中繼檔、legacy-python |
| 10 Photo Organizer | 維持 src/smart_photo_organizer、tests/docs/scripts 與既有 GUI 入口 | 清除不同版本 Python 的位元碼及 pytest 快取 | 現行 .venv、模型/設定及既有 embedded；前輪解除 runtime 追蹤的索引狀態維持 |
| 11 Calendar | 維持純 Web 與 apps-script 分工 | 無必要搬移或刪除 | 現行 v1.1.2 發行包與既有設定 |
| 12 ClipMask | 維持 clipmask/tests/models；驗收文件集中 docs | ACCEPTANCE_RECORD 移入 docs；清除 PyInstaller build 中間檔及舊測試截圖/輔助檔；清除快取 | .venv、ONNX、現行 v1.1.0 Portable 目錄與 ZIP；不改影音或 AI 邏輯 |
| 13 Project Hub | 維持公開靜態站 assets/data/images/downloads | 無必要搬移或刪除 | Photo_Report.rar 是現行頁面引用的 VBA 下載項目，不能當成廢棄發行包刪除 |
| 14 Google Photos | 維持 src/tests/docs，fixtures 與 work 依原契約 | 輸出資料夾規格移入 docs；清除快取；補上繁中 README 連結 | .venv 與 Copy-only 原始資料安全邊界；不變更輸出邏輯 |
| 15 chainflow | 維持 chain_fund_tracer/tests 與隔離的 history/reports | 刪除 38 筆與 test_gui 虛構內容精確吻合的歷史快照並更新索引；清除快取 | 其他 12 筆索引逐欄位保持，其快照及既有報告雜湊保持；正式 API/設定未動 |
| DesktopFramesPlus | 維持 upstream 的 Code/Images/tools/docs 與目前入口 | 刪除 v2.8.1/v2.9.0 舊 ZIP 及 Debug 產物 | 現行 v2.9.4、Release EXE、sandbox/panel-tests 的 Release 產物及使用者配置 |

## 實際執行邊界

- 搬移 4 項，共 14 個檔案，約 138.4 MiB；搬移不算釋放空間。
- 清理 61 項，另移除空 config 及 38 份虛構測試快照。共刪除 1,002 個檔案，623,772,078 位元組（594.88 MiB）；檔案邏輯容量不等於量測磁碟可用空間差值，詳細清冊見 execution.json。
- 舊合成包及舊成品依授權直接移除，沒有留下同容量的備份或隔離包。正式原始碼與測試程式保留。
- 原 history 索引副本存於 Git 忽略的 artifacts/layout-safety；只用於追查與比對，已刪除的虛構快照沒有另外保留。其他案件內容未刪除。
- cases.db 雖為零位元組，但實際雜湊檢查顯示被其他程式鎖定；首次預檢在任何搬移/刪除前停止，排除此檔後才執行。未終止任何其他程式。
- PaperSwitch release_notes.md 實際屬於 v4.3.0，查證後保留。只刪除清冊中可確認為舊版的成品。
- 桌面未找到 SystemOptimizer.lnk，沒有變更個人捷徑。中央未來建立捷徑與建置流程已同步指向 dist。

## 驗證

| 驗證範圍 | 結果與證據 |
|---|---|
| 六個現行 Python 專案環境 | CheckOnly 全部通過，pip check 無損壞依賴；environment-check.log |
| 05 PDF 環境 | pypdf/pdfplumber/fitz 可用；pdf-environment.log |
| 04 邏輯 | 既有四組測試全部通過；photo-unit.log |
| 04 瀏覽器互動 | 既有 Playwright 上傳、去重、復原、燈箱及多選等流程通過；photo-e2e.log |
| 04 匯出基準 | Word XML、Excel 欄位、PDF 頁數/尺寸與三種版型通過；photo-baseline.log |
| 15 歷史功能 | 3 項既有測試通過；使用 TemporaryDirectory，不污染正式 history；history-tests.log |
| 06 入口與建置路徑 | Windows PowerShell 原生入口 ValidateOnly 指向新 dist/standalone；建置 CheckOnly 通過；沒有重新發布或觸發系統清理功能 |
| 09 既有入口 | ValidateOnly 要求重建：dist/publish 原本缺少 EXE，保留的 Release EXE 又被既有原始碼時間檢查判定過舊；本輪沒有移除該入口成品或改其判斷邏輯。現行 v4.3.0 發行 EXE 及 Release EXE 存在 |
| 中央 Skill | sync_codex -CheckOnly 顯示既有部署一致；skill-sync-check.log；本輪未變更憲法或 Skill 內容、未正式同步 |
| 資料、既有修改及 Git | verification.json 記錄逐檔雜湊、歷史索引、17 個 HEAD/分支及工作目錄邊界；沒有 Commit/Push |

本輪測試範圍是目錄整理受影響的入口、素材與資料邊界；沒有將此結果宣稱為 17 個專案所有功能或 Windows 10/乾淨電腦發布驗收。C# 核心及 UI 原始碼沒有改動，保留既有 Release 二進位與建置資產，未為清理而重新建置。

## 已確認、推測與待驗證

**已確認**：清冊中的搬移、刪除、雜湊一致性、套件環境檢查及上述測試結果。現行成品與有效測試素材未列入刪除清單。

**推測**：未被本機現行腳本引用的更早自訂捷徑或外部排程可能仍使用舊路徑；指定桌面捷徑未找到，本輪沒有全面更動外部排程。

**待驗證**：10 原生 WinShellReader 前輪曾等候超過 180 秒的問題，根因與正式介面重現程度仍未確認。舊原始測試輸出依本次要求清除，但診斷事實保留於 Python 環境報告；本輪未修復或重新測試該問題。跨電腦 Portable/發布門檻另次驗證。

## 後續存放原則與回復

正式原始碼、有效 regression fixtures、必要設定範例與文件留在 Git；環境、建置、dist、artifacts 不提交。測試素材使用現有生成器寫入 artifacts/test-runs，不再混在 dist。現行發布包按版本留存，日後確認已替換再清理前版。

檔案搬移的來源、目標與完整雜湊見 operations.json。需要回復時先檢查最新工作目錄：06 可原樣搬回並同步回復入口路徑；已追蹤的舊照片及文件可由 Git 還原，不能以整個 Repository reset 抹除其他修改。已刪除且未被追蹤的舊發布包須由既有原始碼重建或取回相對應正式 Release，本機不保證保留副本。

預覽 PREVIEW.md、基準 baseline.json、執行 execution.json 與驗證 verification.json 保存在本目錄。生成器/執行器會防止誤覆寫本輪清冊或盲目重跑。
