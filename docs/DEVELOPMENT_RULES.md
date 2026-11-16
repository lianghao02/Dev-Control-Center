# 共用開發規則

本文件是使用 Codex、Antigravity 與 Claude Code 協作時的共同工程契約；它不取代各 Repository 的 `AGENTS.md` 與產品規格。

## 共用範圍

- 正式程式、測試、`scripts/`、`docs/` 與 GitHub Actions 在同一個 Repository 中維護。
- 各專案長期邊界預設維護於專案根目錄 `AGENTS.md`；僅在確有平台差異時，才補充至 `.agents/`（Codex）或 `.gemini/`（Antigravity），不得互相複製或複製全域憲法。
- Agent 指引只說明角色與操作入口；可重複執行的驗證流程一律實作在專案腳本中。
- `.venv`、`python_embed`、快取、登入狀態與未提交修改屬於工作區本機資料，不共用也不提交。

## Worktree 協作

主工作區預設承載 `main`（部分專案如 `12` 為 `master`）。需要平行開發或隔離任務時，建議建立獨立工作區（如 `git worktree`）或分支隔離：

- 不讓兩個 Agent 同時操作同一資料夾。
- 建立新工作區前，主分支必須沒有未提交變更，且只允許 `pull --ff-only`。
- 開發完成後先執行適用 QA／測試、提交，再由接手 Agent 檢視分支差異。

## 專案驗證入口

依各 Repository 技術棧執行對應驗證腳本（不要求每個專案皆具備同一組檔名）：

- 設有 `scripts/qa.ps1`（或 `dotnet-src/scripts/qa.ps1`）的專案：執行該 QA 腳本及搭配的 `test.ps1`／`security-check.ps1`。
- Web / Node.js 專案：依 `package.json` 執行 `npm test` 或 `node --check` 語法檢查。
- Python 專案：使用專案受管 `.venv` 或 `python_embed` 執行 `pytest`／`unittest`。

`qa.ps1` 僅串接純自動化檢查，不包含 Office COM、登入瀏覽器、實體裝置或使用者資料操作；這類本機專屬檢查保留在各專案的驗證文件。

## 提交與 CI

- 提交前必須通過適用的本機測試、`git diff --check` 與敏感字串檢查。
- GitHub Actions 只執行可於無頭 Linux 環境重現的檢查。
- Commit 格式採 `type: 台灣繁體中文簡述`；禁止 force push。
