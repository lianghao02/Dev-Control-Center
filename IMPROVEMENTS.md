# 跨專案已確認改善事項總表 (IMPROVEMENTS)

> **定位與原則**：
> 1. 本檔為所有 Repository 的「已確認改善事項」全域唯一彙整表，各 Repository 不自建獨立改善清單。
> 2. 只收錄：**已確認問題**、**已確認有實際效益的改善**、**暫緩項目**與**近期保留之限制**。
> 3. 嚴禁收錄：理論性優化、未驗證猜測、無邊界未來功能或長篇歷史流水帳（歷史明細請查 `docs/` 或 Git Commit）。

---

## 近期已完成與保留限制索引

- **2026-10-25｜`09_PaperSwitch` v4.6.0 已發布**：大圖左鍵拖曳、向量匯出加頁碼（補償旋轉與裁切）、功能圖示清晰化與發布交付完成。
- **2026-10-22｜健檢缺陷修復與批次發布**：`12`、`08`、`02`、`11`、`17`、`18`、`14` 已修訂並發布。待實機項目保留：`08` `file://`、原生 GUI 完整人工操作與手機 PWA 更新（證據：[本輪修訂與發布結果](docs/audit-release-20261022.md)）。
- **2026-10-05～10-16｜環境修復、目錄整理與遠端同步**：完成 Python `.venv`/embedded 隔離、PowerShell 5.1 UTF-8 BOM 修正、README 校準與 `13_Project-Hub` 集中化；`09` Office 輸出遇本機 GoPatrol IGEF 加密限制（詳見 [IGEF 診斷](docs/new-build-acceptance/IGEF-DIAGNOSIS.md)）。其餘歷史證據見 `docs/python-environment-repair/RESULTS.md`、`docs/project-layout/RESULTS.md`、`docs/github-sync/2026-10-12.md`。
- **2026-11-06｜工作區清理與封存**：`06_System-Optimizer-Tool`、`10_Smart-Photo-Organizer`、`20_Daily-Photo-Report-30Days` 已依授權停用或封存並移出本機與同步清冊。

---

## 各專案維護狀態與已知限制

- **`01_AG-MONITOR-Smart-Video-Screening`（維護）**：核心架構穩定，無待處理重大阻斷問題。
- **`04_Photo-Report-Generator`（維護 / v2.3.0）**：已完成單元測試、Playwright E2E、Golden Baseline 與 Tauri 打包發布；僅於真實 Bug、明確業務需求、相容性或安全問題時重開開發。
- **`07_auto-learning-bot`（維護 / V2.1.0）**：已發布 V2.1.0，僅於實際 Bug、公務平臺前端改版或依賴失效時維護。
- **`13_Project-Hub`（維護）**：採純靜態無框架架構與 GitHub Pages 託管；僅於專案新增或正式版本更迭時同步資料陣列。
- **`15_chainflow-inspector`（已廢止 / 封存）**：2026-11-22 停止開發與使用，本機專案資料夾、中央專案清冊及展示站引用已移除；遠端 Repository 依使用者需求辦理移除。

---

## 其餘 Repository 治理邊界
- 其餘專案僅依 GitHub 遠端、專案 `HANDOFF.md` 或已有明確紀錄維護。
- 未經使用者確認或無明確 Bug 回報前，不預先建立推測性待辦項目。
