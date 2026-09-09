# HANDOFF

## 目前狀態
可交付 (Production Ready - v1.6.0 維護修正)

## 2026-09-09 維護修正
- Level 1 改為背景 Job，首次畫面 Render 後啟動；14 專案掃描完成後才由 UI 執行緒更新畫面。
- Tab Header 前景色明確套用至內容；BAT 成功預檢後立即結束 CMD，GUI 程序持續執行。
- Git 狀態改以 porcelain v2 單次查詢取得分支、上游與 ahead/behind；實測掃描 160.953 秒降至 40.301 秒。

## 本輪目標
Dev-Control-Center v1.6「日常操作中心化」：
將 Dev-Control-Center 從分散腳本收斂為以 UI 為中心的日常操作控制中心，優化 UI 啟動效率（秒開）、三級狀態掃描分流（L1 快速本機、L2 遠端重整、L3 完整健康檢查）、整合單項桌面應用程式建置與桌面捷徑檢查、嚴格維護 10 條 Git 安全防線與全自動化驗收測試。

## 已完成
1. **UI 啟動最佳化 (秒開)**：
   - 移除了 `scripts/gui.ps1` 在 `Window.Add_Loaded` 中的阻塞性全域工具鏈 CLI 檢測。
   - 啟動時立即呈現手帳 Shell 視窗，並於背景執行非同步 Level 1 快速本機掃描，徹底實現啟動秒開。
2. **專案總覽三級狀態掃描分流 (14 個 Repository)**：
   - 頂部工具列整合三級操作按鈕：
     - **Level 1（快速掃描）**：僅檢查本機 Working Tree 與本機 HEAD/Upstream 狀態，不執行網路連線，秒級完成。
     - **Level 2（遠端重整）**：執行 safe fetch origin，取得真實雲端領先／落後狀態。
     - **Level 3（完整檢查）**：一鍵檢測 Git 狀態 + 語言工具鏈 + Agent 規則對齊度 + 桌面建置狀態 + 桌面捷徑完整性。
   - 專案清單 DataGrid 增加「版本」欄位，透過 `scripts/lib/bootstrap.ps1` 之 `Get-RepositoryVersion` 動態解析版號。
3. **桌面程式建置與捷徑管理中心化**：
   - 擴充 `build_all_desktop_apps.ps1`，支援 `[string]$Project = ''` 指定單一專案建置與預覽，保留互動選單與 `-Force` 相容性。
   - 預覽模式明確回傳 ExitCode 0，確保管線呼叫穩定性。
   - GUI 桌面建置 Tab 新增「建置選取項目」與「檢查桌面捷徑」按鈕，整合 `Test-DesktopShortcutsStatus` 檢查桌面 `.lnk` 存在與目標路徑。
4. **既有腳本相容性與命令列整合**：
   - `scripts/workspace_sync_hub.ps1` 擴充 `QuickScan` 模式與輸出格式對齊。
   - 保持所有獨立 PowerShell 腳本命令列參數相容，不破壞批次檔 (`.bat`) 呼叫習慣。
5. **日誌與治理強化**：
   - GUI 操作與狀態掃描即時輸出至 `logs/dev-control-center.log`。
   - 全自動驗收測試套件 `scripts/tests/test_v16_acceptance.ps1` 擴充涵蓋 11 大核心測試，通過率 100%。

## 刻意未修改
- 未重寫現有架構，未引入大型外部框架（無 Electron、Tauri 或額外 npm 相依性）。
- 未改動其他 13 個業務專案的業務程式碼。
- 嚴格遵守 10 條安全防線：絕不 Force Push、絕不自動 Commit/Stash、遇到 Modified/Diverged 嚴格略過。

## 尚未完成
- 無

## 驗證結果

### 已執行
- `scripts/tests/test_v16_acceptance.ps1`：
  - [PASS] 1. Repository 狀態掃描測試 (14 專案)
  - [PASS] 2. Clean Repository 測試
  - [PASS] 3. Modified Repository 測試 (安全略過未提交變更)
  - [PASS] 4. Ahead Repository 測試 (識別待 Push 數量)
  - [PASS] 5. Behind Repository 測試 (識別待 Pull 數量)
  - [PASS] 6. 無法連線或 Remote 查詢失敗情境 (安全顯示『無法確認』)
  - [PASS] 7. Build 腳本成功／失敗處理測試 (預覽模式與退出碼驗證)
  - [PASS] 8. Missing Repository 顯示測試
  - [PASS] 9. 單一 Repository 失敗、不影響其他測試 (隔離性驗證)
  - [PASS] 10. 啟動 GUI 並完成一次基本操作流程 (XAML 與 5 大分頁控制項載入驗證)
  - [PASS] 11. 專案版本號解析功能驗證 (`Get-RepositoryVersion`)
  - **測試統計：通過 11 / 失敗 0 (共 11 項，100% 通過)**。
- 專案版本號解析與 XAML 控制項驗證通過。
- `build_all_desktop_apps.ps1` 與 `scripts/gui.ps1` 語法嚴格解析通過。

### 尚未驗證
- 無

### 已知風險
- 無

## Git 狀態
- `00_Dev-Control-Center`：
  - 目標版本：v1.6.0
  - 分支：main
  - 遠端：https://github.com/lianghao02/Dev-Control-Center.git
  - 狀態：所有功能修改與測試腳本已就緒，即將提交並推送至遠端。

## 下一步
- 日常開發時直接雙擊 `0_控制中心_手帳儀表板.bat` 啟動主控台，享受秒開與一鍵三級掃描體驗。
