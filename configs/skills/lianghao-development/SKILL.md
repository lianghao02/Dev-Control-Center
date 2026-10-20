---
name: lianghao-development
description: LiangHao 跨 Agent 軟體工程與專案治理標準技能庫。提供標準化 AUDIT、EVALUATE、FIX、IMPROVE、RELEASE 與跨平台 HANDOFF 流程，支援 ChatGPT、Antigravity、Codex 共用規範。
---

# 🛡️ LiangHao Development Standard Skill (v1.0.0)

本技能為 LiangHao 個人開發生態系之工程實踐與專案治理參考，由 **Dev-Control-Center** 作為 Canonical Source 統一維護。

## 1. 核心原則與邊界

1. **環境可攜性（Zero Hard-coded Paths）**：
   - 嚴禁硬編碼本機固定磁碟或使用者目錄。
   - 所有路徑解析遵循動態解析順序：環境變數 `LIANGHAO_SKILL_HOME` ➜ `%USERPROFILE%\\.lianghao\\config.json` ➜ 鄰近目錄探索。
2. **單一治理真理源（Single Source of Truth）**：
   - `Dev-Control-Center/configs/skills/lianghao-development/` 為唯一 Canonical Source。
   - 各 Repository 僅保留專案專屬限制與最小引用，不複製完整 Skill。
3. **安全操作防線**：
   - 未獲使用者授權，不得 Force Push、`reset --hard` 或抹除未提交修改。
   - AUDIT 與引導式需求探索／產品決策（EVALUATE 探索模式）任務預設僅唯讀分析，不得變更程式碼或檔案。

## 2. 六大任務型態與四類任務分流

| 任務型態 | 分類 | 目標與行為限制 | 成果產出 | 參考 Workflow |
|:---|:---|:---|:---|:---|
| **AUDIT** | A. 檢查任務 | **唯讀健康檢查**。掃描 Git 狀態、測試涵蓋、敏感資料與相依套件風險。 | 專案健康評估表、風險清單 | `workflows/audit-project.md` |
| **EVALUATE** | D. 需求探索／產品決策 | **專案定位、引導式需求探索與產品決策**。評估功能清晰度、現場痛點與開源參照，或透過動態問卷引導探索，產出處置決策或產品方向決策摘要（預設唯讀）。 | `project-scorecard.md` 或產品方向決策摘要 | `workflows/evaluate-project.md` |
| **FIX** | B. 修正／改善任務 | **精準 Bug 修復**。先重現問題、最小必要修改與真實驗證，不發散重構無關模組。 | 修復程式碼、回歸測試證據 | `workflows/fix-project.md` |
| **IMPROVE** | B. 修正／改善任務 | **架構或體驗優化**。依明確需求改善效能或體驗，保留可驗證的前後證據。 | 優化程式碼、基準比對資料 | `workflows/improve-project.md` |
| **RELEASE** | C. 發布／結案任務 | **版本發布與交付**。執行 Release Gate、更新變更紀錄與建立發布報告。 | `release-report.md`、發行檔 | `workflows/release-project.md` |
| **HANDOFF** | C. 發布／結案任務 | **跨 Agent 標準交接**。記錄工作斷點、驗證證據與後續建議。 | `HANDOFF.md` | `workflows/handoff-project.md` |

## 3. 開源軟體參照與專案處置矩陣

執行 EVALUATE 任務時，外部開源專案分為三類：

- **Direct Competitor**：功能與目標使用者高度重疊，評估本專案是否有必要差異化。
- **Partial Reference**：僅參考特定模組、演算法或操作流程。
- **Technical Reference**：僅作為函式庫、驅動或協定規格參考。

評估後應選擇一個明確處置：**Build**、**Build + Reference**、**Adopt + Extend**、**Adopt**、**Freeze** 或 **Archive**（既有專案探索時亦應判斷：**維持現況**、**局部改善**、**功能擴充**、**重大改版** 或 **暫不決定**）。

## 4. 跨 Agent 交接標準

跨 Agent 交接不得以本機絕對路徑作為主要識別。交接檔以以下五項元資料鎖定工作情境：

1. **Repository Full Name**（例如 `lianghao02/PaperSwitch`）
2. **Branch**（例如 `main` 或 `codex/dev`）
3. **Commit SHA**（例如 `a687db`）
4. **Skill Version**（例如 `1.0.0`）
5. **Task Type**（AUDIT / EVALUATE / FIX / IMPROVE / RELEASE / HANDOFF）

詳細欄位請參閱 `templates/handoff.md` 與 `workflows/handoff-project.md`。

## 5. 目錄導覽與資源指引

- **規範文件（`references/`）**：
  - `project-governance.md`：專案治理與文件權威劃分。
  - `agent-execution.md`：Agent 執行邊界與停止條件；第 3 節為 UI／UX 自主風格探索、開源參考與驗證原則，第 4 節為遊戲風格工具 UI 設計與選型規範，第 5 節為任務分類。
  - `release-policy.md`：發布標準、語意化版本與驗收規範。
  - `project-product-assessment.md`：產品評估、痛點分析與開源參照決策；第 4 節為依需求選用技術設計參考，第 5 節為 Agent 引導式需求探索與產品決策規範。
  - `windows-development.md`：Windows 開發、動態路徑、編碼防禦與薄 BAT 原則。
  - `python-environments.md`：Python 環境盤點、`.venv` 與 embedded 隔離及啟動器修復規範。
  - `data-safety.md`：機敏資料與不可逆操作防護。
- **標準工作流程（`workflows/`）**：`audit-project.md`、`evaluate-project.md`、`fix-project.md`、`improve-project.md`、`release-project.md`、`handoff-project.md`。
- **範本庫（`templates/`）**：`agent-task.md`、`handoff.md`、`project-scorecard.md`、`release-report.md`。
- **檢核清單（`checklists/`）**：`baseline.md`、`post-change.md`、`release-gate.md`、`sensitive-data.md`。

- Python 環境盤點、隔離或啟動器修復時，讀取 `references/python-environments.md`。
- 使用者要求規劃產品、探索方向、問卷引導或重新評估專案時，讀取 `references/project-product-assessment.md` 第 5 節；若需求已明確或要求直接修改，則直接執行不強制啟動問卷。
- 新介面設計、明確 UI／UX 改善、視覺風格探索、遊戲風格工具 UI 選型、UI 預覽圖、手機／桌面／響應式調整或主要流程 UX 問題時，讀取 `references/agent-execution.md` 第 3、4 節；一般非 UI 任務不強制研究案例。
- 大型新專案、跨模組功能、架構調整或重大資料／API／安全／復原取捨時，依需要讀取 `references/project-product-assessment.md` 第 4 節；一般局部修改不強制外部研究或新增設計文件。
- 遊戲架構設計（本機與 Web 網頁遊戲）、核心玩法循環、狀態機邏輯、GDD 規格或遊戲介面與 HUD 時，載入並讀取 `game-design` Skill（工具軟體套用遊戲風格 UI 時一併遵循 `references/agent-execution.md` 第 4 節）。
