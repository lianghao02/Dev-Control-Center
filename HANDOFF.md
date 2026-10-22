# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：432e087（本輪修改前基準；交付以包含本交接之提交為準）
- **Skill Version**：v1.0.0
- **Task Type**：AUDIT / IMPROVE / HANDOFF
- **Local Path Hint**：00_Dev-Control-Center

---

## 目前狀態
2026-10-22：本輪已授權的跨專案文件、測試與圖片改善均已提交推送，13 正式站驗收通過；中央由包含本交接之提交收尾並核對遠端。19 全程排除。

## 本輪目標
收尾 13／16／18、完成 07 上游維護分析、補齊 15 CHANGELOG、建立實機驗收步驟並交付。

## 基準與已確認事實 (Baseline & Confirmed Facts)
中央起始 main／432e087、Clean；各專案基準與最終提交、部署工作及線上檔案雜湊統一見 docs/post-refactor-delivery.md，不重複保存流水帳。

## 已完成 (Completed)
- 13 五張無損 WebP 減少 27.40%，像素一致；正式站 7/7 檔案與提交一致，搜尋／分類／圖片載入通過，console 0。
- 16 正式版補三組回歸，97/97 通過；beta 審查文件分開提交推送，不合併或刪分支。
- 18 交接更正已推送；98/98 測試成果繼承，測試重建產物已還原。
- 07 上游維護與模組地圖已推送；15 未發布 CHANGELOG 已推送、匯出回歸 5/5，版號不變。
- 13／16／18 Pages 工作成功，正式站產品檔案核對通過。

## 異動檔案 (Changed Files)
中央：IMPLEMENTATION_PLAN.md、HANDOFF.md、docs/post-refactor-acceptance.md、docs/post-refactor-delivery.md。其他成果已各自在所屬專案／分支提交。

## 刻意未修改 (Do Not Do / Deliberately Omitted)
未動全域規則、Skills 或 19，無須同步中央設定。未大拆 07、未整批合併或刪除 16 分支；未升版或建立 Release。04／02 實機驗收不虛列通過。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：本輪交付無已知阻斷。
- **P2 (重要/當次)**：中央本提交完成後核對 push、工作目錄與追蹤分支；不需要再新增一筆自我記錄提交。
- **P3 (改善建議/暫緩)**：04 原生視窗畫面、02 真實手機已安裝 PWA 更新待實機；07 上游候選與 16 題庫／PWA 另依明確需求處理。

## 驗證結果 (Validation)
### 已執行測試與結果
16 97/97、18 98/98、15 匯出 5/5；13 正式站與已推送提交逐位元組相同、瀏覽器操作通過；diff --check 與本輪敏感字串檢查通過。細節與 URL 見交付結果。
### 尚未驗證項目
04 桌面畫面與 02 真實手機更新未執行；07 未重跑完整平台操作、15 未重跑完整 GUI。
### 已知風險 (Known Risks)
04 標題設定沒有版本後綴，版本應另核對應用程式內顯示。保留的 PNG 與 WebP 增加版本庫容量，但正式引用下載量下降。

## Git 狀態
- Commit：包含本交接之提交，以 git log 為準。
- Push：本輪已授權；中央此提交後核對，其他專案已成功。
- Working Tree：本輪提交範圍僅上述四份中央文件；提交後核對 Clean。
- Branch：main。

## 下一步建議動作 (Next Recommended Action)
本輪交付完成後停止擴大修改；後續僅依實機結果或明確功能需求啟動，不重做已完成拆分。

## 發布狀態 (Release Status)
13 展示站圖片改善已部署；16 與 18 既有工作流程部署成功，產品程式與版號維持原樣。本輪未建立新 Release。

---

## 前輪交接（歷史參考）

# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：880010d5221d884474468b8b8da8bb50fddc3fd5（本輪修改前基準；交付提交以包含本交接的 Git 記錄為準）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：00_Dev-Control-Center

---

## 目前狀態
可交付（2026-10-21：收斂中樞入口與同步腳本、選單白話化、Claude Code 加入部署目標、三平台用語與技能觸發描述修訂、憲法文件職責與事實判斷釐清；已正式同步並驗證）。

## 本輪目標
使用者反映中樞「開發到後來亂掉、看不懂 UI 要做什麼」。本輪收斂為單一入口與單一同步腳本，讓選單白話易懂，並把 Claude Code 納入與 Codex、Antigravity 同等的規則與技能部署。

## 基準與已確認事實 (Baseline & Confirmed Facts)
- 開始時 main 位於 880010d，Working Tree 為 Clean。
- 中樞原有兩套入口（終端選單、WPF GUI）與四套同步邏輯（`sync_projects.ps1`、`workspace_sync_hub.ps1`、`push_projects.ps1`、GUI 內建 git merge／push）；GUI 專案數寫死 14 個，清冊實際為 18 個。
- `push_projects.ps1` 未被任何入口引用，且帶有自動 commit 參數。
- 開始時 Claude Code 沒有 `~/.claude/skills/` 與 `~/.claude/CLAUDE.md`，只靠雲端入口技能臨時讀取規則。

## 已完成 (Completed)
1. **入口收斂**：只保留 `0_開發中樞.bat` → `scripts/dev-hub.ps1`；移除 GUI（`0_控制中心_手帳儀表板.bat`、`scripts/gui.ps1`、`scripts/gui/MainWindow.xaml`），選單移除「開啟 GUI」。
2. **同步收斂**：只保留 `scripts/workspace_sync_hub.ps1`；移除 `scripts/sync_projects.ps1`、`scripts/push_projects.ps1`。README 新增入口與功能對照表、新電腦流程改用 `dev-hub.ps1 -Action`；專案 `AGENTS.md` 明定單一入口與單一同步腳本。
3. **選單白話化**：每個選項改為白話描述並加註是否會動到檔案；[4] 子選單先說明 1／2 的差別。
4. **Claude Code 部署**：`scripts/sync_codex.ps1` 將 15 個共用 Skills 部署至 `~/.claude/skills/`，並產生 `~/.claude/CLAUDE.md`（以 `@` 匯入 `configs/AGENTS.md`，憲法修訂後不需重新部署）；`skill-creator` 不部署至 Claude。安全刪除白名單只加入這兩個 Claude 路徑。
5. **三平台用語**：憲法 4.2 改為「多 Agent」，`webapp-testing`、`project-readiness-check`、`document-to-markdown`、`project-governance.md`、`skill-creator` 改為三平台中性寫法。
6. **憲法精簡與技能觸發**：憲法第 3 節「引導式需求探索」「UI／UX 風格探索」縮為摘要並指向 Skill（刪除的細節已確認保留於 `agent-execution.md`、`product-design`、`game-design`）；`lianghao-development`、`safe-data-processing`、`taiwan-office-automation`、`windows-tool-ux` 描述補上中文觸發情境。
7. **文件職責與事實判斷**：憲法 4.1 補入 `MEMORY.md` 定位（歷史參考）；衝突判斷拆為「規則優先順序」與「現況以 Git／實測為準」；4.3 讀取順序註明 README／MEMORY 僅需要背景時讀取。
8. **測試修正**：`test_v16_acceptance.ps1` 的 GUI 測試改為終端入口測試；原本寫死 14 專案而失敗的掃描測試改為依清冊數量。`verify-agent-environment.ps1`、`test_skill_environment.ps1` 一併驗證 Claude 目錄。
9. **前輪交接修復**：前一版 HANDOFF 有 6 處 PowerShell 反引號跳脫被寫成控制字元，導致 Git 將本檔視為二進位；已修復。
10. **正式同步**：`sync_codex.ps1 -Execute` 兩次（Claude 首次部署 18 項；用語與觸發描述修訂 24 項）。

## 異動檔案 (Changed Files)
- 刪除：`0_控制中心_手帳儀表板.bat`、`scripts/gui.ps1`、`scripts/gui/MainWindow.xaml`、`scripts/sync_projects.ps1`、`scripts/push_projects.ps1`
- 腳本：`scripts/dev-hub.ps1`、`scripts/sync_codex.ps1`、`scripts/verify-agent-environment.ps1`、`scripts/verify_project_layout.py`、`scripts/tests/test_v16_acceptance.ps1`、`scripts/tests/test_skill_environment.ps1`
- 規則與技能：`configs/AGENTS.md`、`configs/skills/{document-to-markdown,lianghao-development,project-readiness-check,safe-data-processing,skill-creator,taiwan-office-automation,webapp-testing,windows-tool-ux}/SKILL.md`、`configs/skills/lianghao-development/references/project-governance.md`
- 文件：`AGENTS.md`、`README.md`、`MEMORY.md`、`CHANGELOG.md`、`HANDOFF.md`
- 本 Repository 以外（工作區根目錄非 Git，不在本次提交）：`D:\Development\GitHub\MEMORY.md` 重寫、`D:\Development\GitHub\AGENTS.md` 對齊讀取順序並加入 CLAUDE.md 限制；原檔備份於 `.memory/MEMORY.archive-20261021.md`、`.memory/AGENTS.workspace-archive-20261021.md`。

## 刻意未修改 (Do Not Do / Deliberately Omitted)
- 未重做 GUI；建議先使用終端選單一段時間，確認實際缺口再決定。
- 未修改 `configs/skills-manifest.json`（未新增 `claudeOnly` 分類）。
- 未拆分 `product-design/SKILL.md`（27 KB 單檔，列為 P3）。
- 未停用雲端 `lianghao-governance-entry` 技能（需使用者於 claude.ai 自行操作）。
- 未推送。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無。
- **P2 (重要/當次)**：無。
- **P3 (改善建議/暫緩)**：
  - GUI 原有「檢查桌面捷徑」「只建置單一程式」終端選單未提供，需要時再加選項。
  - 選單 [3] 選了就直接編譯全部，無二次確認。
  - `scripts/verify_project_layout.py` 依賴已不存在的 `artifacts/layout-safety/history_index.before.json`，執行失敗（與本輪無關）。
  - `product-design/SKILL.md` 可拆分為 `SKILL.md` + `references/`。
  - 雲端 `lianghao-governance-entry` 技能已與本機設定重複，可考慮停用。

## 驗證結果 (Validation)
### 已執行測試與結果
- `dev-hub.ps1 -Action QuickScan`：18 個專案完成掃描。
- 選單於 Windows PowerShell 5.1 實際顯示，中文正常。
- `scripts/tests/test_v16_acceptance.ps1`：11／11 通過。
- `scripts/verify-agent-environment.ps1`：ALL PASS（Codex、Antigravity、Claude Code TreeHash 一致）。
- `scripts/tests/test_skill_environment.ps1`：8／8 通過。
- `sync_codex.ps1 -CheckOnly`：同步後全部 Current。
- 16 個 Skill 的 YAML frontmatter 皆可解析；`git diff --check` 無錯誤。
- Claude Code 於工作區以外（桌面）開新工作階段，可直接答出憲法 v8.5，確認 `~/.claude/CLAUDE.md` 匯入生效。
### 尚未驗證項目
- 選單 [2] 安全同步、[3] 建置、[5] 環境檢查未於本輪實際執行（腳本本身未修改）。
- 新的技能觸發描述是否提高 Claude 自動載入命中率，尚未實測。
### 已知風險 (Known Risks)
- 刪除的 GUI 與同步腳本只能從 Git 歷史取回（880010d 之前）。
- `~/.claude/CLAUDE.md` 匯入的是本機絕對路徑；換電腦後需重跑 [4] 產生。

## Git 狀態
- Commit：見包含本交接的提交
- Push：否
- Working Tree：提交後 Clean
- Branch：main

## 下一步建議動作 (Next Recommended Action)
使用者確認後推送 main；實際使用終端選單一段時間，再決定是否補選項或重做 GUI 外殼。

## 發布狀態 (Release Status)
不適用（管理腳本與規則，無發行包）。

---

## 歷史交接快照（以下不是當前待辦或測試結果）

# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：f0308e9960303cb1a38b7d48cb6f53d280703a3c（本輪修改前基準；交付提交以包含本交接的 Git 記錄為準）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：00_Dev-Control-Center

## 目前狀態
可交付（2026-10-20：完成全域開發憲法與共用 Skills 修訂，整合「Agent 引導式需求探索與產品決策」、「UI／UX 自主風格探索與開源參考」及「遊戲風格工具 UI 設計與選型」，並完成 Codex／Antigravity 雙平台同步部署與驗證）。

## 本輪目標
依「GitHub 共用 Agent 規則修訂任務書」整合產品需求探索、UI／UX 自主風格探索與遊戲風格工具 UI 選型規範至既有共用規則與 Skills，不新增冗餘文件，不修改業務專案程式碼。

## 基準與已確認事實 (Baseline & Confirmed Facts)
開始時 main 與 origin/main 同步（f0308e9），Working Tree 為 Clean。configs/AGENTS.md 與 configs/skills/ 為雙平台唯一正式來源，透過 scripts/sync_codex.ps1 部署。

## 已完成 (Completed)
1. **全域開發憲法（configs/AGENTS.md）**：於第 3 節補充「引導式需求探索與產品決策」及「UI／UX 自主風格探索、真實案例參考與遊戲風格工具 UI 選型」核心啟動與邊界，並更新第 6 節 Skill 路由表。
2. **引導式需求探索與產品決策（lianghao-development）**：
   - 於 references/project-product-assessment.md 新增第 5 節（適用範圍、啟動條件、既有專案先理解現況 7 項確認、每輪 3～5 題動態問卷、9 種回答自由度、主動分析責任、結束條件、11 項產品方向決策摘要與既有專案 5 種處置判斷、預設唯讀執行邊界）。
   - 更新 SKILL.md 與 workflows/evaluate-project.md，整合「D. 需求探索／產品決策任務」流程並與檢查（A）、修正／改善（B）、發布／結案（C）任務明確區分。
   - 修正 workflows/release-project.md 與 templates/release-report.md 殘留之大陸用語「文檔」為「文件」。
3. **UI／UX 自主風格探索與遊戲風格工具 UI 選型（agent-execution.md、product-design、game-design、project-planning）**：
   - 於 references/agent-execution.md 擴充第 3 節（設計前研究 2～3 個可查證案例、未指定與已指定風格處理、避免 6 類制式 AI 介面、10 項 UI／UX 驗證指標）與新增第 4 節（遊戲風格工具 UI 設計與選型規範：遊戲類型與美術風格分離、不預設 Q 版、保留工具軟體本質、預覽圖與實作分離、各專案保有特色、成熟專案改版限制）及第 5 節（A/B/C/D 任務分類）。
   - 同步更新 product-design/SKILL.md（第 0.0 節）、game-design/SKILL.md（新增第 1.1 節工具型產品套用遊戲風格 UI 邊界）與 project-planning/SKILL.md（純探索訪談分流）。
4. **雙平台同步與環境驗證**：執行 sync_codex.ps1 -Execute -SkipMcpConfig，更新 Codex 與 Antigravity 全域憲法及共用 Skills。

## 異動檔案 (Changed Files)
- configs/AGENTS.md
- configs/skills/lianghao-development/SKILL.md
- configs/skills/lianghao-development/references/agent-execution.md
- configs/skills/lianghao-development/references/project-product-assessment.md
- configs/skills/lianghao-development/workflows/evaluate-project.md
- configs/skills/lianghao-development/workflows/release-project.md
- configs/skills/lianghao-development/templates/release-report.md
- configs/skills/product-design/SKILL.md
- configs/skills/game-design/SKILL.md
- configs/skills/project-planning/SKILL.md
- HANDOFF.md

## 刻意未修改 (Do Not Do / Deliberately Omitted)
未新增重複之獨立 Skill 或額外參考檔；未修改任何產品 Repository 之業務邏輯、UI 或正式規格；未變動 configs/skills-manifest.json 分流清單。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無。
- **P2 (重要/當次)**：無（前輪跨專案事項繼承）。
- **P3 (改善建議/暫緩)**：無。

## 驗證結果 (Validation)
### 已執行測試與結果
- scripts/sync_codex.ps1 -CheckOnly -SkipMcpConfig：部署後 33 項受管目標全數 Current。
- scripts/verify-agent-environment.ps1：全數通過（ALL PASS，24 項 Canonical 檔案與雙平台 TreeHash 一致）。
- scripts/tests/test_skill_environment.ps1：8／8 測試全數通過。
- 情境 A～F 規範覆蓋檢核：6／6 情境皆有明確啟動條件、現況讀取、風格選型、預覽分離與直接執行邊界對應。
- 大陸禁用語掃描與 git diff --check：0 違規、0 格式錯誤。
### 尚未驗證項目
純治理規則修訂，未執行各業務產品應用程式 Build。
### 已知風險 (Known Risks)
無。

## Git 狀態
- Commit：本輪獨立提交，SHA 以 Git 記錄為準。
- Push：推送至 origin/main 並核對遠端 SHA。
- Working Tree：提交後為 Clean。
- Branch：main。

## 下一步建議動作 (Next Recommended Action)
後續於各專案啟動產品探索、UI 設計或遊戲風格工具 UI 預覽／改版時，直接依更新後之全域憲法與共用 Skills 執行。

## 發布狀態 (Release Status)
治理規則更新已同步部署至本機雙平台並推送遠端，不另建立應用程式 Release。

---

# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：0ea3887a69e3fa5e18f20fb6582475b0a66b756d（本輪修改前基準；交付提交以包含本交接的 Git 記錄為準）
- **Skill Version**：v1.0.0
- **Task Type**：HANDOFF
- **Local Path Hint**：00_Dev-Control-Center

## 目前狀態
2026-10-16：已重新核對保留的 18 個倉庫；依使用者確認，移除已廢棄的 10、20 本機資料夾並更新同步清單。保留前輪修正及未提交修改。

## 本輪目標
同步遠端提交狀態、清理使用者確認已刪除的專案並保留交接斷點。

## 基準與已確認事實 (Baseline & Confirmed Facts)
GitHub 帳號可讀 18 個自有倉庫；18 個保留本機倉庫已 fetch，追蹤分支 ahead／behind 均為 0／0。武俠正式 master 位於 .codex/worktrees/wuxia-v2.2.3，原始資料夾 beta 未覆寫。使用者確認 10、20 已廢棄並從 GitHub 刪除。

## 已完成 (Completed)
14 完成兩項缺陷修正及回歸測試；13 校正四張版本卡片；11 校正轉導文件；16 區分 beta 與 master。武俠 v2.2.3 已另行正式發布。10、20 已移至資源回收筒；停止 20 的 Vite／esbuild 後完成清理。同步清單移除 10，保留 18 個目標。

## 異動檔案 (Changed Files)
development-repositories.json、README.md、IMPROVEMENTS.md、HANDOFF.md；產品差異分別留在各倉庫。

## 刻意未修改 (Do Not Do / Deliberately Omitted)
未修改來源資產、既有發布包、全域憲法與共用 Skills；本輪提交並推送既有修正，不另建立 Release。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：本輪已重現的 Google 相簿阻斷缺陷已修正；舊發布包仍待正式修補。
- **P2 (重要/當次)**：10、20 清理已完成；00、11、13、14 的修正與文件於本輪分別提交推送；16 原始 beta 交接修改保留。
- **P3 (改善建議/暫緩)**：其他專案重構不在本輪範圍。

## 驗證結果 (Validation)
### 已執行測試與結果
18 個倉庫重新 fetch 後提交均一致；刪除目標路徑、Git 狀態與占用程序已檢查，兩個原路徑已不存在。同步清單 JSON 含 18 個唯一目標，均有對應本機資料夾。前輪 14 測試 31／31 通過；13 資料、JavaScript 語法與瀏覽器驗證通過。
### 尚未驗證項目
10、20 清理已完成；00、11、13、14 的修正與文件於本輪分別提交推送；16 原始 beta 交接修改保留。
CheckOnly 已執行，部分既有全域憲法與技能部署顯示 Pending；本輪未變更這些來源，也未執行正式同步。
### 已知風險 (Known Risks)
原始碼修正不會自動更新既有下載包或正式部署。

## Git 狀態
- Commit：本輪差異獨立提交；SHA 以包含本交接的 Git 記錄為準。
- Push：交付時核對 HEAD 與遠端追蹤分支一致。
- Working Tree：提交後以 git status 確認，未納入無關修改。
- Branch：main。

## 下一步建議動作 (Next Recommended Action)
核對各倉庫推送結果；Google 相簿修補版的版號與下載包仍須另行發布驗證。

## 發布狀態 (Release Status)
本輪同步修正提交，不另建立 Release，未同步 Agent 設定。

---

---

# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：c84f4fb6afeb7dccaa2b44cc25d934b8e0e25159（本輪文件提交前基準；最新以 Git log 為準）
- **Skill Version**：v1.0.0
- **Task Type**：HANDOFF
- **Local Path Hint**：00_Dev-Control-Center

---

## 目前狀態
2026-10-12：完成工作區專案編號，18_AromaCraft-Studio／19_DesktopFramesPlus 保留原 GitHub 儲存庫；更新 development-repositories.json、DesktopFrames 成品套用路徑及 Project-Hub 版本同步對照。既有修改與個人 Profiles 雜湊不變；既有 Desktop Frames 開機啟動路徑已校正。本次編號調整已獲提交與推送授權；前輪未完成事項繼承。

DesktopFramesPlus 本機新版已套用並啟動，代表性 Data 面板／便箋與 10／12／15 合成功能通過。09 Office 三種輸出均為 IGEF，正常轉 PDF 仍受環境阻斷；防護與獨立標準 PDF 功能通過。前輪環境修復、目錄與 README 成果繼承；本輪不是正式發布。

## 本輪目標
承接成品套用與代表性驗收，釐清 09 的 IGEF 辦公室加密環境限制；校正說明、保留既有功能與文件保護，明確記錄未通過的 Office 可讀性。

## 基準與已確認事實 (Baseline & Confirmed Facts)
上述 SHA 為修復前已存在的 HEAD。既有功能成果承接原版本，不重做或撤銷；詳細跨專案基準位於控制中心 docs/python-environment-repair/baseline.json。

## 已完成 (Completed)
2026-10-06 同步結果：16 個成果提交已推送，遠端 SHA 一致；已觸發 CI 全部完成。05 略過、07 原有兩個修改保留；9 個保護檔案雜湊與 1,011 個 runtime 留存核對通過。完整 SHA／CI 連結見 `docs/github-sync/RESULTS.md`。本交接與報告收尾另以單一 docs 提交同步，不建立 Release。

2026-10-06 GitHub 同步交接：使用者已授權提交與推送前輪成果；本輪只提交已核對範圍。最新 Commit SHA、遠端同步與 CI 結果統一見控制中心 `docs/github-sync/RESULTS.md`，不將提交本身的 SHA 寫入同一份提交。 本輪補正 PowerShell 5.1 中文腳本編碼：僅增加 UTF-8 BOM，原內容位元組不變；29 個相關腳本在 5.1／7 語法檢查均通過，環境 CheckOnly 亦通過。

2026-10-06 IGEF 診斷：確認 GoPatrol 服務與保護驅動正在執行、Office 外掛註冊及有效簽章，依辦公室文件加密限制追蹤；精確規則未確認。補充 PowerShell COM 對照逾時，未產出 PDF，未列成功，僅回收本輪隱藏 Word；Office 殘留 0。校正 README 的 IGEF 說明，產品程式與系統保護未改。詳見 docs/new-build-acceptance/IGEF-DIAGNOSIS.md。

2026-10-06 成品驗收：DesktopFramesPlus 13 項功能斷言通過，正常退出後備份與套用 22 個程式檔，128 個保護檔案不變；新版啟動前後 124 個 Profiles 檔案雜湊一致。10 使用正式 Shell 重新生成素材與分析，12 遮罩字幕／剪輯、15 六格式離線匯出通過。09 三份 Office 輸出為 IGEF，正常轉檔未通過；既有拒絕機制、標準 PDF 合併／旋轉／分頁及 COM 清理通過。詳見 docs/new-build-acceptance/RESULTS.md。

2026-10-06：10 正式 Shell 讀寫期限／冪等啟動／回收與 8 項回歸，完整測試 148 項（147 通過、1 略過）；DesktopFramesPlus 版本來源、入口與發布包版本防護，獨立 MSBuild 2.9.4.0／記憶體轉移／繁中鍵／雙主機入口測試通過，現行成品與 Profiles 保留。保護清冊唯一差異為活動日誌，未覆寫還原。證據見 docs/remaining-fixes/RESULTS.md。

2026-10-05 PaperSwitch 入口修復：排除生成來源誤判、支援有效 Release 回退、修正 PowerShell 5.1 編碼並補齊 publish EXE；建置不再先刪除整個輸出目錄。16 項入口回歸、50 項核心測試與主視窗啟動通過，46 個既有資料檔案不變。09 交接與中央待辦已更新；證據見 docs/paperswitch-launch-repair/RESULTS.md。

2026-10-05 README 文件更新：補齊專案概念、開發原因、典型流程、已知 Bug／限制及回報方式，並依實際入口校正必要操作說明。本次沒有修改產品程式、環境或個人資料，未 Commit／Push；前輪成果與既有待辦繼承。文件檢核與逐案索引由控制中心 docs/readme-refresh/RESULTS.md 彙整，不代表本次重新驗收全部功能。

2026-10-05 目錄整理：4 項搬移、1,002 個舊產物/快取清理（594.88 MiB）；06 入口/建置路由改至根目錄 dist，中央設定範例合併 configs，15 只清除 38 筆可證實的虛構歷史。逐專案配置與保護清冊見 docs/project-layout/RESULTS.md。cases.db 鎖定而保留，PaperSwitch v4.3.0 發行說明經查證保留。

跨專案環境修復；四個 Skill 正式來源移至 configs/skills；憲法、解析、選擇性同步與中央建置路由修正，已部署雙平台。

前輪合成驗收生成器保留，未來寫入 Git 忽略的 artifacts/test-runs/synthetic-acceptance；舊 dist 素材包已依本輪清理要求移除。當時結果及 10 Shell 逾時事實保留於 docs/python-environment-repair/SYNTHETIC-ACCEPTANCE.md；後續正式後端無限等待防護已修復，驗證由新報告記錄，不改寫舊結果。

## 異動檔案 (Changed Files)
本次僅新增 IGEF 診斷報告，更新中央結果報告／IMPROVEMENTS／交接及 09 README／HANDOFF；診斷宿主與證據在 Git 忽略的 artifacts。前輪受控套用與代表性工具成果繼承；沒有變更產品程式、憲法、Skill 或部署設定。

configs/AGENTS.md、configs/skills、scripts、setup_all_envs.ps1、build_all_desktop_apps.ps1、規劃與驗證報告。

本次目錄整理新增盤點/清冊/執行/驗證工具及報告，最小更新 06、中央路由與受影響文件；不變更業務演算法。前輪生成器只調整未來輸出位置。

## 刻意未修改 (Do Not Do / Deliberately Omitted)
前輪環境修復／整理未變更全域 Python／PATH／全域套件、現行成品內容、業務演算法或原始資料，只移除清冊中已確認的舊產物。此次僅重新產生 09 本機開發成品，正式獨立發布包不變。未 Commit／Push。07 原有兩個檔案修改保留且已核對雜湊。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無已確認的現行開發環境阻斷。
- **P2 (重要/待外部流程)**：09 Office 正常轉 PDF 受 IGEF 阻斷，依辦公室文件加密限制追蹤；GoPatrol 元件正在執行，精確規則未確認。須以單位核准的標準 PDF 產出／讀取流程再驗收，不更動保護。DesktopFramesPlus 本機新版已套用。
- **P3 (改善建議/暫緩)**：舊發布包不會因來源修正自動更新；下一次發布另驗證乾淨電腦與隔離入口。全域套件及共用 cv2 去重另案處理。

## 驗證結果 (Validation)
### 已執行測試與結果
本輪 IGEF 診斷：5 個保護檔案 SHA-256 一致、兩個 Repository HEAD／分支／索引不變；本輪文件差異及語言檢查通過。Office 殘留 0，DesktopFramesPlus 2.9.4.0 仍在執行。補充 PowerShell COM 對照逾時未通過，僅回收本輪 Word；另一次唯讀 Git 檢查停滯，回收後完成狀態／索引與文件範圍核對，不推定與保護元件有因果關係。未修改產品 C#，未重跑未受影響的核心測試。

此次：10 全套回歸及正式 Shell 重跑、DesktopFramesPlus 獨立建置／版本／入口／圖示轉移／繁中資源通過；完整證據見 docs/remaining-fixes/RESULTS.md。

前輪：六個現行 Python 環境、05 PDF 與 Skill CheckOnly 通過；04 四組單元、Playwright 與 Golden Baseline 通過；15 三項隔離歷史測試通過；06 原生 ValidateOnly/建置 CheckOnly 通過；17 個 HEAD/分支與資料核對詳見 docs/project-layout/verification.json。09 當時要求重建的紀錄保留；後續已修復，兩種 PowerShell ValidateOnly 與發布 EXE 啟動通過，見入口修復報告。

五個專案 450 項測試（3 項略過）；環境邊界 5 項、Skill 8 項通過；完整證據見 docs/python-environment-repair/RESULTS.md。
### 尚未驗證項目
Win10／其他使用者／無全域 Python 電腦、完整原生介面互動、真人素材、線上採集與正式重新打包未驗證；本機 DesktopFramesPlus 已完成受控更新，09 正常 Office 轉檔未通過。
### 已知風險 (Known Risks)
完整明細與回復方式見控制中心 docs/python-environment-repair/RESULTS.md；不可將新 .venv 的驗證視為舊 Portable 包已修復。

## Git 狀態
- Commit：089ca715964a49f127f5781c094f70c7ebb900b9（已同步的成果提交；報告收尾提交的最新 SHA 見 Git HEAD）。
- Push：16 個成果提交已推送並核對遠端 SHA；報告收尾提交另行同步。
- Working Tree：成果推送後中央為 Clean；本交接、報告與改善總表三個檔案另行提交。07 原有兩個修改保留、05 略過。
- Branch：main。

## 下一步建議動作 (Next Recommended Action)
日常使用新版 DesktopFramesPlus dist 入口。09 依單位核准流程取得可讀標準 PDF，再驗收 Office（可讀 3、阻斷 0、來源不變與 Office 殘留 0）；目前不擴大修改演算法或保護策略。其他暫緩事項繼承；提交與正式發布另依授權及發布門檻。

## 發布狀態 (Release Status)
本輪沒有建立新發布版；既有版本保留。


## 2026-10-12 全專案同步交接

使用者已授權所有專案提交／推送及更新事項。4 個產品成果已推送並核對遠端 SHA，14 個產品原已同步；本中樞另提交同步報告、CHANGELOG、改善總表與交接。05 遠端不存在，已本機提交且詢問重建私人儲存庫，尚未獲答案。完整結果以 docs/github-sync/2026-10-12.md 為本輪真理來源。

11 只推 codex/firebase-family，不觸發 main Pages；17 遠端為私人。無本輪 Release、正式站切換或 Apps Script 部署；各案待驗收維持，私人資料與設定不納入 Git。本輪未修改憲法、共用 Skills 或中央部署設定。

## 2026-10-14 UI／UX 真實案例參考規範交接

### 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：44a3acea8351a4de38b5efb2de233d45ee29dff6（本輪修改前基準；本輪提交 SHA 以 Git log 為準）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：00_Dev-Control-Center

### 目前狀態
共用規範與必要部署已完成，相關驗證通過；提交與推送狀態以 Git HEAD／origin/main 為準。

### 本輪目標
將 UI／UX 真實案例參考原則納入既有共用治理，不修改應用程式或發布流程。

### 基準與已確認事實 (Baseline & Confirmed Facts)
開始時 main 與 origin/main 同步、Working Tree 為 Clean。專案 AGENTS、README、manifest 與同步腳本共同確認 configs/AGENTS.md 與 configs/skills/ 為唯一正式來源；Codex／Antigravity 共用同一來源，透過 scripts/sync_codex.ps1 單向部署。既有 product-design 提供介面設計工法，但沒有本次完整案例來源與真實性規範。

### 已完成 (Completed)
在既有 agent-execution.md 第 3 節加入適用時機、六個候選來源、選擇方式、來源真實性、存取限制與三類任務邊界；憲法及技能入口只加入引用。先 CheckOnly，再 Execute -SkipMcpConfig，雙平台各更新憲法與 lianghao-development；保留既有備份，其餘項目一致。

### 異動檔案 (Changed Files)
- configs/AGENTS.md
- configs/skills/lianghao-development/SKILL.md
- configs/skills/lianghao-development/references/agent-execution.md
- HANDOFF.md（追加本輪交接，保留既有內容）

### 刻意未修改 (Do Not Do / Deliberately Omitted)
各應用程式、個別 Repository AGENTS、前端框架、MCP、Skill 分流清單、Release Gate 與 P1／P2／P3 分級皆未修改；未新增 Skill 或安裝服務。

### 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：本輪無。
- **P2 (重要/當次)**：本輪無；前輪 Office／IGEF 等未完成事項繼承，未重新驗收。
- **P3 (改善建議/暫緩)**：候選網站可存取範圍可能變動，後續 UI 任務仍須依實際取得資料提供可核對案例。

### 驗證結果 (Validation)
#### 已執行測試與結果
- sync_codex.ps1 -CheckOnly -SkipMcpConfig：部署前僅四項 Pending，無 Modified／Unmanaged；部署後全部 Current。
- scripts/tests/test_skill_environment.ps1：8 項通過、0 失敗，含動態解析、可攜路徑、安全合併及雙平台 TreeHash 一致性。
- git diff --check 與差異審查通過；原有規範保留，非 UI 任務不強制研究，美化不延後發布。
- 候選首頁檢查：Banani、Design Spells、Mobbin 取得內容；Refero 未取得可讀內文，Screenlane 工具存取失敗，UI Sources 導向 screensdesign.com。未據此宣稱完成特定產品案例研究。
#### 尚未驗證項目
未測試未來 Agent 在所有 UI 任務中的執行行為；純文件變更不執行應用程式 Build。
#### 已知風險 (Known Risks)
外部登入／付費／存取條件可能改變，規範已要求如實回報並以可驗證資料繼續。

### Git 狀態
- Commit：本輪以 docs 提交；實際 SHA 見 Git log，避免自我引用。
- Push：依使用者本次授權推送原有 origin/main，結果以遠端 SHA 核對。
- Working Tree：提交後應為 Clean，最終由 git status 確認。
- Branch：main。

### 下一步建議動作 (Next Recommended Action)
後續符合條件的 UI 任務讀取 agent-execution.md 第 3 節；非 UI 任務維持既有流程。

### 發布狀態 (Release Status)
本輪為治理文件更新，未建立應用程式 Release；既有發布門檻不變。

## 2026-10-14 依專案需求補充技術與互動參考交接

### 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：f247c50d7b8b2e13f480353609a4d10d8e3c620c（本輪基準；成果 SHA 以 Git log 為準）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：00_Dev-Control-Center

### 目前狀態
規範補充與雙平台同步完成，驗證通過；承接前輪提交／推送授權，最終狀態由 Git 核對。

### 本輪目標
依行政資料、Windows 桌面與輕量 Web 專案需求補充參考選擇，避免研究與文件負擔擴大。

### 基準與已確認事實 (Baseline & Confirmed Facts)
開始時 main／origin/main 同步、Working Tree 為 Clean；沿用既有中央來源、manifest 與 sync_codex.ps1。前輪 UI／UX 原則與其他未完成事項繼承。

### 已完成 (Completed)
技術評估第 4 節加入 Design Docs、Atlassian 及按需範本／架構清單，聚焦資料安全、環境可攜與維護成本；UI 原則加入 UI-Patterns、Page Flows 及限商業需求的 GoodUI，區分真實案例、模式、範本與實驗證據。局部修正不強制研究或新增文件，未量測不宣稱效益數字。更新技能入口引用；同步只更新雙平台 lianghao-development。

### 異動檔案 (Changed Files)
configs/skills/lianghao-development/SKILL.md、references/agent-execution.md、references/project-product-assessment.md（後兩者位於同一技能目錄）及 HANDOFF.md。

### 刻意未修改 (Do Not Do / Deliberately Omitted)
未修改應用程式、全域憲法、MCP、分流與同步腳本、發布門檻及問題分級；未新增 Skill、框架、服務或強制文件。Kimi 與 Awwwards 不列必要來源；Mobbin 不重複新增。

### 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：本輪無。
- **P2 (重要/當次)**：本輪無，前輪事項繼承。
- **P3 (改善建議/暫緩)**：外部來源依後續任務實際存取與內容判斷。

### 驗證結果 (Validation)
#### 已執行測試與結果
CheckOnly 部署前僅雙平台 lianghao-development Pending，無 Modified／Unmanaged；Execute -SkipMcpConfig 完成備份與同步，部署後全部 Current。test_skill_environment.ps1 通過 8／8，含原生目錄與 TreeHash 一致性。git diff --check 與本輪差異審查通過，原有章節與規則保留。
#### 尚未驗證項目
未實測未來 Agent 對各專案的研究行為；純文件變更不執行應用程式 Build。本輪沿用上一輪已核對的候選來源，不宣稱新增產品案例研究。
#### 已知風險 (Known Risks)
來源存取與內容可能改變，仍須查核原始文件；外部實驗不保證本案成效。

### Git 狀態
- Commit：本輪 docs 提交，SHA 見 Git log。
- Push：依本次延續任務推送原有 origin/main，以遠端 SHA 核對結果。
- Working Tree：提交後由 git status 確認。
- Branch：main。

### 下一步建議動作 (Next Recommended Action)
後續按未解決的決策或操作問題選用資料，足以完成本次驗證後停止研究。

### 發布狀態 (Release Status)
治理文件更新，不建立應用程式 Release，既有發布門檻不變。

## 2026-10-14 遊戲架構設計與 UI 專家技能雙平台共用交接（含 Web 遊戲約束規範）

### 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：28bc94b912239634d0b7eb5c8b3fbcfd401a7d65（本輪基準；成果 SHA 以 Git log 為準）
- **Skill Version**：v8.5
- **Task Type**：FEAT
- **Local Path Hint**：00_Dev-Control-Center

### 目前狀態
已建立獨立 `game-design` 技能庫，納入雙平台共用分流清單並成功部署至 Codex 與 Antigravity；全域憲法與共用操作參考已完成路由與清單更新，完整涵蓋本機遊戲（PC/Console）與 Web 網頁遊戲（HTML5/WebGL）。

### 本輪目標
將遊戲架構設計、核心玩法循環、狀態機邏輯、極端邊界防護與六大遊戲介面資料庫（本機三大：Interface In Game、Game UI Database、GameUI Net；Web 網頁三大：Poki、CrazyGames、Itch.io）及 Web 遊戲專用約束模組封裝為獨立 Skill，並讓 Codex 與 Antigravity 雙平台共用。

### 基準與已確認事實 (Baseline & Confirmed Facts)
開始時工作區為 Clean；沿用 `configs/skills-manifest.json` 與 `sync_codex.ps1` 雙平台分流部署架構，確保無非預期修改。

### 已完成 (Completed)
1. 擴充 `configs/skills/game-design/SKILL.md`：
   - 封裝遊戲系統架構、六大遊戲 UI 資料庫引用原則、核心循環、狀態機思維、一/二/三級資訊層級、I/O 規範、極值邊界防護與品質自我檢核表。
   - 新增 **Web 遊戲專用架構與 UI 約束規範**：16:9 畫布與 Safe Frame 9 宮格錨點防裁切、Drawer/Modal 空間節流替代常駐多欄、情境浮動 HUD、44×44 CSS 像素雙模操作容錯、Fullscreen 降級防下拉重新整理、首屏 15MB 限制與輕量補間動畫原則、HUD 佔比 <= 20% 與選單層級 <= 2 層驗收標準。
2. 維護 `configs/skills-manifest.json`：`game-design` 位於 `shared` 清單，支援 Codex 與 Antigravity 雙平台共用。
3. 更新 `configs/AGENTS.md`：在第 6 節 Skill 路由表補入本機與 Web 網頁遊戲架構設計、狀態機與 HUD/抽屜式排版情境。
4. 更新 `configs/skills/lianghao-development`：在 `references/agent-execution.md` 補充本機與 Web 遊戲介面、HUD 與空間節流參考清單，並在 `SKILL.md` 加入讀取指引。
5. 執行 `sync_codex.ps1 -Execute`：已成功將新 Skill 與設定檔同步部署至 `~/.agents/skills/game-design` (Codex) 與 `~/.gemini/config/skills/game-design` (Antigravity)，以及雙平台的 `AGENTS.md`。

### 異動檔案 (Changed Files)
- `configs/skills/game-design/SKILL.md`
- `configs/AGENTS.md`
- `configs/skills/lianghao-development/SKILL.md`
- `configs/skills/lianghao-development/references/agent-execution.md`
- `HANDOFF.md`

### 刻意未修改 (Do Not Do / Deliberately Omitted)
未直接將遊戲專用名詞與龐大提示詞硬塞入全域憲法本體，避免非遊戲專案 Token 浪費；未變更 MCP 設定或應用程式本體程式碼。

### 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無。
- **P2 (重要/當次)**：無。
- **P3 (改善建議/暫緩)**：未來遊戲相關專案（如 11_TypingLegend、Web 互動展示）可依需要進一步於專案級 AGENTS.md 宣告特定機制。

### 驗證結果 (Validation)
#### 已執行測試與結果
- `sync_codex.ps1 -Execute` 執行無誤，雙平台檔案已確認同步（含 Poki、CrazyGames、Itch.io 與 Safe Frame 錨點機制）。
- `Select-String` 實體驗證 `~/.agents/skills/game-design/SKILL.md` (Codex) 與 `~/.gemini/config/skills/game-design/SKILL.md` (Antigravity) 內容一致。
- `git diff --check` 無多餘空白或編碼問題。
#### 尚未驗證項目
- 未實測未來遊戲專案呼叫時的實際互動生成，待相關專案任務實測。

### Git 狀態
- Commit：本輪以 feat 提交。
- Push：待交付後依指引推送至遠端。
- Branch：main。

### 下一步建議動作 (Next Recommended Action)
在開發打字遊戲（11_TypingLegend）、Web 網頁遊戲或涉及遊戲機制/介面設計時，直接由 Codex 或 Antigravity 載入 `game-design` Skill。

## 2026-10-16 全域憲法與 Skills 規則衝突消弭及周邊文件更新交接

### 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：ad5860ded7d6c53722ee3bfbd540fbcb1d4ea98c（本輪修改前基準；最新以 Git log 為準）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：00_Dev-Control-Center

### 目前狀態
可交付（全域憲法、共用 Skills 衝突條文修正、PowerShell 5.1 UTF-8 BOM 補齊、雙平台同步部署與 19 專案／16 預設技能文件更新皆已完成並通過實測驗證）。

### 本輪目標
檢查並消除全域開發憲法（`configs/AGENTS.md`）與各個 Skills／周邊治理文件之間的規則衝突、大陸用語殘留與硬編碼路徑，並將 `README.md`、`docs/CODEX_SETUP.md`、`docs/PROJECT_ARCHITECTURE_GUIDE.md` 同步更新為 19 個專案與 16 個預設技能。

### 基準與已確認事實 (Baseline & Confirmed Facts)
開始時 `main` 與 `origin/main` 同步（`ad5860ded7d6c53722ee3bfbd540fbcb1d4ea98c`），Working Tree 為 Clean。

### 已完成 (Completed)
1. **消除 UTF-8 BOM 規則與 PowerShell 5.1 實測衝突**：
   - 更新 `configs/AGENTS.md` 與 `configs/skills/lianghao-development/references/windows-development.md`：明確區分 JSON／Markdown／設定檔／一般原始碼預設使用無 BOM 的 UTF-8，而含中文字元且需相容 Windows PowerShell 5.1 的 `.ps1` 腳本須使用 UTF-8 with BOM。
   - 為 6 個缺少 UTF-8 BOM 的含中文 `.ps1` 腳本（`dev-hub.ps1`、`push_projects.ps1`、`sync_projects.ps1`、`verify-agent-environment.ps1`、`workspace_sync_hub.ps1`、`test_git_status.ps1`）補齊 UTF-8 BOM，並修正 `test_skill_environment.ps1` 在 PS 5.1 不支援 `-Encoding utf8NoBOM` 的問題。
2. **消除 Skills 間條文衝突與硬編碼路徑**：
   - `product-design/SKILL.md`：新增 `00.0 — LiangHao 工作區治理對齊原則`，對齊台灣繁體中文、Windows／離線工具優先採用系統字型堆疊（`Segoe UI`, `Microsoft JhengHei UI`, `system-ui`）、非阻斷式需求探索與依專案規模裁剪狀態門檻。
   - `game-design/SKILL.md`：修正第 4.5 節，次要細節預設合理假設推進，惟核心目標或平台不明時仍向使用者簡明確認。
   - `accesslint/SKILL.md`：對齊 `webapp-testing` 與 `data-safety.md`，優先使用既有瀏覽器測試與本機離線 `axe.min.js`，禁止臨時 `pip install playwright` 或於公務離線專案注入外部 CDN。
   - `skill-creator/SKILL.md`：移除硬編碼 `D:\Development\GitHub` 與舊使用者路徑，改用相對路徑與 `%USERPROFILE%`。
   - `lianghao-development`：修正 `release-policy.md` 大陸用語「文檔」為「文件」，並於 `SKILL.md` 與 `verify-agent-environment.ps1` 補入 `references/python-environments.md`。
3. **周邊治理文件更新（19 個專案、16 個預設 Skills）**：
   - 更新 `README.md`、`docs/CODEX_SETUP.md`、`docs/PROJECT_ARCHITECTURE_GUIDE.md` 與 `docs/DEVELOPMENT_RULES.md`。
4. **雙平台同步部署**：執行 `sync_codex.ps1 -Execute -SkipMcpConfig`，將更新後之 `AGENTS.md` 與 Skills 同步至 Codex 與 Antigravity。

### 異動檔案 (Changed Files)
- `configs/AGENTS.md`
- `configs/skills/accesslint/SKILL.md`
- `configs/skills/game-design/SKILL.md`
- `configs/skills/lianghao-development/SKILL.md`
- `configs/skills/lianghao-development/references/release-policy.md`
- `configs/skills/lianghao-development/references/windows-development.md`
- `configs/skills/product-design/SKILL.md`
- `configs/skills/skill-creator/SKILL.md`
- `README.md`
- `docs/CODEX_SETUP.md`
- `docs/DEVELOPMENT_RULES.md`
- `docs/PROJECT_ARCHITECTURE_GUIDE.md`
- `scripts/dev-hub.ps1`、`scripts/push_projects.ps1`、`scripts/sync_projects.ps1`、`scripts/verify-agent-environment.ps1`、`scripts/workspace_sync_hub.ps1`、`scripts/tests/test_git_status.ps1`、`scripts/tests/test_skill_environment.ps1`
- `HANDOFF.md`

### 刻意未修改 (Do Not Do / Deliberately Omitted)
未修改各業務專案程式碼、MCP 設定或 `configs/skills-manifest.json` 分流結構。

### 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無。
- **P2 (重要/當次)**：無（前輪 09 IGEF 等跨專案事項繼承）。
- **P3 (改善建議/暫緩)**：Antigravity 外掛目錄 `%USERPROFILE%\.gemini\config\plugins\product-design` 與 `%USERPROFILE%\.gemini\config\skills\product-design` 重複載入同名 Skill，若日後不需外掛版可於 Antigravity 外掛管理停用。

### 驗證結果 (Validation)
#### 已執行測試與結果
- Windows PowerShell 5.1 全專案 23 個 `.ps1` 腳本 AST 語法檢查：23／23 通過（0 錯誤）。
- `scripts/sync_codex.ps1 -Execute -SkipMcpConfig` 與 `-CheckOnly`：34 項受管項目全數 `Current`。
- `scripts/verify-agent-environment.ps1`（PS 5.1 實測）：全數通過（ALL PASS，含 24 項 Canonical 結構與雙平台 TreeHash 一致）。
- `scripts/tests/test_skill_environment.ps1`（PS 5.1 實測）：8／8 測試全數通過。
- `git diff --check`：無空白或格式錯誤。

### Git 狀態
- Commit：尚未提交（待使用者指示是否 commit / push）。
- Push：否。
- Working Tree：Modified（僅限上述本輪治理文件與腳本 BOM 修正）。
- Branch：main。

### 下一步建議動作 (Next Recommended Action)
確認差異無誤後，可依需求提交（建議 Commit 訊息：`docs: 消除全域憲法與技能規則衝突並更新 19 專案與 16 技能文件`）。

### 發布狀態 (Release Status)
治理文件與測試腳本相容性更新，不涉及應用程式正式版發布。