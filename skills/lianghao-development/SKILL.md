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
   - `Dev-Control-Center/skills/lianghao-development/` 為唯一 Canonical Source。
   - 各 Repository 僅保留專案專屬限制與最小引用，不複製完整 Skill。
3. **安全操作防線**：
   - 未獲使用者授權，不得 Force Push、`reset --hard` 或抹除未提交修改。
   - AUDIT 任務僅能唯讀掃描，不得變更程式碼或檔案。

## 2. 六大任務型態

| 任務型態 | 目標與行為限制 | 成果產出 | 參考 Workflow |
|:---|:---|:---|:---|
| **AUDIT** | **唯讀健康檢查**。掃描 Git 狀態、測試涵蓋、敏感資料與相依套件風險。 | 專案健康評估表、風險清單 | `workflows/audit-project.md` |
| **EVALUATE** | **專案定位與架構評估**。評估功能清晰度、現場痛點與開源參照，產出處置決策。 | `project-scorecard.md` | `workflows/evaluate-project.md` |
| **FIX** | **精準 Bug 修復**。先重現問題、最小必要修改與真實驗證，不發散重構無關模組。 | 修復程式碼、回歸測試證據 | `workflows/fix-project.md` |
| **IMPROVE** | **架構或體驗優化**。依明確需求改善效能或體驗，保留可驗證的前後證據。 | 優化程式碼、基準比對資料 | `workflows/improve-project.md` |
| **RELEASE** | **版本發布與交付**。執行 Release Gate、更新變更紀錄與建立發布報告。 | `release-report.md`、發行檔 | `workflows/release-project.md` |
| **HANDOFF** | **跨 Agent 標準交接**。記錄工作斷點、驗證證據與後續建議。 | `HANDOFF.md` | `workflows/handoff-project.md` |

## 3. 開源軟體參照與專案處置矩陣

執行 EVALUATE 任務時，外部開源專案分為三類：

- **Direct Competitor**：功能與目標使用者高度重疊，評估本專案是否有必要差異化。
- **Partial Reference**：僅參考特定模組、演算法或操作流程。
- **Technical Reference**：僅作為函式庫、驅動或協定規格參考。

評估後應選擇一個明確處置：**Build**、**Build + Reference**、**Adopt + Extend**、**Adopt**、**Freeze** 或 **Archive**。

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
  - `agent-execution.md`：Agent 執行邊界、停止條件與防衛準則。
  - `release-policy.md`：發布標準、語意化版本與驗收規範。
  - `project-product-assessment.md`：產品評估、痛點分析與開源參照決策。
  - `windows-development.md`：Windows 開發、動態路徑、編碼防禦與薄 BAT 原則。
  - `data-safety.md`：機敏資料與不可逆操作防護。
- **標準工作流程（`workflows/`）**：`audit-project.md`、`evaluate-project.md`、`fix-project.md`、`improve-project.md`、`release-project.md`、`handoff-project.md`。
- **範本庫（`templates/`）**：`agent-task.md`、`handoff.md`、`project-scorecard.md`、`release-report.md`。
- **檢核清單（`checklists/`）**：`baseline.md`、`post-change.md`、`release-gate.md`、`sensitive-data.md`。
