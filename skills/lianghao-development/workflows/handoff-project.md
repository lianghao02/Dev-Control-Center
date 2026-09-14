# HANDOFF 跨 Agent 交接流程 (Handoff Workflow)

## 核心原則：無路徑依賴之連續性交接
1. **鎖定交接元資料**：
   - `Repository Full Name`
   - `Branch`
   - `Commit SHA`
   - `Skill Version`
   - `Task Type`
   - *（本機絕對路徑僅作參考資訊，不得作為唯一辨識依據）*
2. **整理工作狀態**：
   - 當前狀態（可交付 / 進行中 / 待驗證 / 阻塞）。
   - 已完成項目與刻意未修改項目。
   - 驗證結果（已執行實測與證據、尚未驗證、已知風險）。
3. **更新專案 HANDOFF.md**：
   - 依照 `templates/handoff.md` 標準結構填寫。
   - 確保下一個 Agent 能從斷點直接平順接手。
