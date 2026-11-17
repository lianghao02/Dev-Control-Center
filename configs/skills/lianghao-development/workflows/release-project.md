# RELEASE 專案發布流程 (Release Workflow)

## 發布檢核道門 (Release Gates)
1. **Git 潔淨與同步檢核**：
   - Working Tree 為 Clean 狀態。
   - 分支已與遠端對齊，無衝突或遺漏提交。
2. **完整測試與建置驗收**：
   - 執行全套自動化測試，通過率 100%。
   - 若為桌面或可攜應用，完成建置並於跨路徑／乾淨環境驗證可正常啟動（詳見 [發布清單](../checklists/release-gate.md)，其中包含適用的 Windows 10／11 雙系統驗收）。
3. **版本號與文件更新**：
   - 同步更新所有版本宣告檔、`README.md` 與 `CHANGELOG.md`（繁體中文發布說明與亮點）。
   - 於 `00_Dev-Control-Center` 執行 `python scripts/check_release_versions.py <專案編號>` 確認無 `ERR`。
4. **機敏資訊與路徑檢驗**：
   - 確認發布檔案未包含任何敏感資訊或本機個人絕對路徑。
5. **標記與展示同步 (Gate 4a)**：
   - 發布後建立 annotated tag（`vX.Y.Z`）並推送（網頁型專案亦同）。
   - 執行 `check_release_versions.py --online` 核對 tag 與 Release 不落後，並同步更新 `13_Project-Hub` 展示版本。
6. **產出發布報告**：
   - 依 `templates/release-report.md` 產出發布總結。
