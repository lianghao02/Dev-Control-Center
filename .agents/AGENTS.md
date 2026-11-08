# Codex 專案指引 — 00_Dev-Control-Center

本專案全域開發憲法唯一正式來源為 `configs/AGENTS.md`，專案專屬規則見根目錄 `AGENTS.md`。

- 進入本專案時，遵循根目錄 `AGENTS.md` 之中央開發中樞定位與 BAT 薄啟動器原則。
- 變更全域憲法或共用 Skills 後，先以 `powershell -ExecutionPolicy Bypass -File scripts\sync_codex.ps1 -CheckOnly` 預覽，確認無誤後始得正式同步。
