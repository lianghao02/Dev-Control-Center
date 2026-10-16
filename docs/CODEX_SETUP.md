# Codex 與 Antigravity 環境摘要

| 項目 | 類型 | 來源 | 安裝位置 | 用途 | 更新／移除 |
|---|---|---|---|---|---|
| 全域憲法 | 共用設定 | `configs/AGENTS.md` | `%USERPROFILE%/.codex/AGENTS.md`、`%USERPROFILE%/.gemini/config/AGENTS.md` | 兩平台共用行為規則 | 修改中央來源後執行 `scripts/sync_codex.ps1`；勿直接改部署檔。 |
| 預設自訂 Skills（共 16 個：15 個共用 + 1 個 Antigravity 專用） | Skill | `configs/skills/`（依 `configs/skills-manifest.json` 分流） | Codex（15 個）：`%USERPROFILE%/.agents/skills/`；Antigravity（16 個）：`%USERPROFILE%/.gemini/config/skills/` | 工程治理、公務自動化、資料安全、Windows/Web/遊戲設計、規劃與交付檢查 | 修改中央來源後執行同步；移除前先封存部署目錄。 |
| skill-creator（Codex 端） | Codex 系統 Skill | Codex 內建 | `%USERPROFILE%/.codex/skills/.system/skill-creator/` | 建立或維護 Skill（Antigravity 端則由 `configs/skills/skill-creator` 同步） | Codex 端由系統維護；Antigravity 端由控制中心分流部署。 |
| MarkItDown | 本機工具 | [Microsoft MarkItDown](https://github.com/microsoft/markitdown) | `%LOCALAPPDATA%/LiangHao/tools/markitdown/.venv/` | PDF、Office 與資料檔轉 Markdown | 依 `document-to-markdown` Skill 的安裝指令更新；刪除該獨立工具資料夾即可移除。 |

## 同步

於 `00_Dev-Control-Center` 目錄下執行：

```powershell
# 唯讀檢查
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync_codex.ps1 -CheckOnly

# 正式同步
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\sync_codex.ps1 -Execute
```

Codex 系統目錄 `%USERPROFILE%/.codex/skills/.system/` 與 Antigravity 平台內建 Skills 不在同步或移除範圍內。

舊備份預設保留；只有明確加上 `-PruneBackups` 才會清除超過 10 份的同步備份。
