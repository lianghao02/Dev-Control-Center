# 專案治理與治理文件職責劃分 (Project Governance)

## 1. 核心定位與真理來源 (Source of Truth)
- 各層級文件權限明確劃分，彼此不重複保存相同資訊，避免維護衝突。
- **規則衝突優先順序**（決定「該怎麼做」）：
  1. 使用者當次明確指示（不得違反全域憲法安全與憑證底線）
  2. 專案 `AGENTS.md` 之長期邊界與例外
  3. 全域 `configs/AGENTS.md` 之通用基準
  4. 最新有效 `HANDOFF.md` 之工作斷點與狀態
  5. `00_Dev-Control-Center/IMPROVEMENTS.md` 跨專案改善總表
- **現況事實判定**（決定「目前是什麼狀態」）：任何文件描述與 Git Commit / Diff、Working Tree 或實測結果不一致時，一律以 **Git 實況與實測證據** 為準，並在交接時更正過時文件。

## 2. 文件職責界定
- `AGENTS.md`：定義專案專屬邊界、技術棧限制、Worktree 與核心驗證指令。嚴禁複製全域憲法。
- `HANDOFF.md`：記錄當前工作交接斷點。回答前一個 Agent 做到哪裡、Git 狀態與下一步。
- `README.md`：專案定位、安裝與使用說明。
- `ARCHITECTURE.md`：模組架構、管線資料流與技術選型邊界。
- `CHANGELOG.md`：標準發布版本日誌。
- `IMPLEMENTATION_PLAN.md`：中大型工作階段之需求規劃與拆解清單。

## 3. 多 Agent 與 Worktree 協作邊界
- Codex、Antigravity 與 Claude Code 共用單一 `HANDOFF.md`，嚴禁建立個人專屬交接檔。
- 未經授權不得覆寫對方專屬之內部設定檔目錄。
