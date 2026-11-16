# HANDOFF

## 核心元資料 (Metadata)
- **Repository**：lianghao02/Dev-Control-Center
- **Branch**：main
- **Commit SHA**：776c0051ceff43fb1e3c95800b028bec01e82918（本輪修改尚未提交）
- **Skill Version**：v1.0.0
- **Task Type**：IMPROVE
- **Local Path Hint**：`00_Dev-Control-Center`

---

## 目前狀態
可交付（待使用者確認後分別提交／推送各異動 Repository）

## 本輪目標
盤點並清理全域憲法（`configs/AGENTS.md`）、共用 Skills（`configs/skills/*`）、`00_Dev-Control-Center` 文件與環境腳本，以及各專案既有 `.agents/`／`.gemini/` 規則中的冗贅、衝突與過時項目，並執行中央同步與自動化驗證。

## 基準與已確認事實 (Baseline & Confirmed Facts)
- **專案清冊對齊**：`development-repositories.json` 現行納管 17 個 Repository（已無已刪除之 `05`、`06`、`10`、`20`）；5 個現行 Python 專案為 `01`、`07`、`12`、`14`、`15`。
- **同步對象**：`scripts/sync_codex.ps1` 將全域憲法與共用 Skills 部署至 Codex（`~/.codex/AGENTS.md`、`~/.agents/skills`）、Antigravity（`~/.gemini/config/AGENTS.md`、`~/.gemini/config/skills`）與 Claude Code（`~/.claude/CLAUDE.md`、`~/.claude/skills`）。
- **核心錨點保留**：`lianghao-development` 維持 `VERSION = 1.0.0` 與既有 24 項標準檔案／目錄路徑，確保 `verify-agent-environment.ps1` 與 `test_skill_environment.ps1` 相容通過。

## 已完成 (Completed)
1. **全域憲法精簡與去重（v8.5 → v8.6）**：
   - `configs/AGENTS.md` 消除與 `lianghao-development` 重複的檢查項目，將手動維護之 17 列 Skill 路由表收斂為依 YAML `description` 自動觸發加上特例邊界，精簡禁止語彙清單並對齊最新現況優先順序與 Web/Tauri 選型原則。
2. **`lianghao-development` 與核心驗證口徑對齊**：
   - `references/project-governance.md` 區分「規則衝突 4 層優先順序」與「現況事實以 Git／實測為準」。
   - `workflows/release-project.md` 與 `templates/release-report.md` 補齊 `check_release_versions.py`、`release-gate.md` 與 `Gate 4a`（Annotated Tag、`--online` 檢查、`13_Project-Hub` 同步）。
   - `SKILL.md` 精簡底部重複路由文字並完整保留 24 項路徑。
3. **共用 Skills 瘦身、模組化與工具鏈對齊**：
   - `product-design/SKILL.md` 由 471 行精簡為 45 行全繁中入口，拆出 `references/design-standards.md` 與 `references/ai-interface-patterns.md`。
   - `webapp-testing/SKILL.md` 對齊 Antigravity 內建 `browser` subagent、`playwright` MCP 與 `chrome-devtools` MCP。
   - `accesslint/SKILL.md` 明確區分本機離線 `axe.min.js` 合規掃描與 `chrome-devtools-plugin`（`a11y-debugging`）。
   - `addyosmani-perf/SKILL.md` 移除過時 `2024` 標記，補充對照 `chrome-devtools-plugin`（`debug-optimize-lcp`、`memory-leak-debugging`）。
   - `game-design/SKILL.md` §1.1 改為引用 `lianghao-development/references/agent-execution.md` §4，消除重複條文。
   - `configs/skills-manifest.json` 補上 `claudePrompt` / `defaultPrompt` 並釐清選用平台覆寫與各技術棧驗證腳本口徑。
4. **控制中心文件與環境腳本對齊 17 專案**：
   - 更新 `README.md`、`IMPROVEMENTS.md` 與 `docs/` 下 `PROJECT_ARCHITECTURE_GUIDE.md`、`DEVELOPMENT_ENVIRONMENT.md`、`CODEX_SETUP.md`、`DEVELOPMENT_RULES.md` 至 17 專案／三平台口徑並移除已刪除專案（`06`、`10`）。
   - 自 `setup_all_envs.ps1`、`scripts/setup_environment_hub.ps1`、`scripts/setup_developer_tools.ps1` 移除已刪除的 `10_Smart-Photo-Organizer`。
5. **跨專案冗餘與違規規則檔清理（共 11 個 Repository）**：
   - 刪除過時或重複的 `.agents/`／`.gemini/` 檔案：`00`（`.agents/AGENTS.md`）、`01`、`02`、`03`（含過時 `.agents/skill.json`）、`04`、`07`、`08`、`09`、`11`。
   - 將 `03_Police-Image-Toolkit/.agents/AGENTS.md` 內有效專案規格（MVVM、XAML `<Resources>` 位置規則、`scripts/build.ps1`、`scripts/qa.ps1`）併回 `03_Police-Image-Toolkit/AGENTS.md`。
   - 移除 `00`、`01`、`02`、`03`、`04`、`07`、`08`、`09`、`11`、`12`、`14` 根目錄 `AGENTS.md` 底部已過時的 Discovery Rule 冗餘段落。
6. **測試腳本修復與對齊**：
   - `scripts/tests/test_python_environment_boundaries.py` 移除已刪除專案（`05_tw-formal-writing`、`10_Smart-Photo-Organizer`）之測試案例，改以現行 `12_ClipMask-AI` 與 `15_chainflow-inspector` 驗證啟動器參數、`-CheckOnly` 不寫檔與錯誤版本防護邊界。
   - `scripts/tests/test_git_status.ps1` 補齊 `Invoke-NativeGit` 暫切換 `$ErrorActionPreference = 'Continue'` 改以 `$LASTEXITCODE` 判定，並將過時斷言 `Synced` 對齊 `scripts/lib/git-status.ps1` 之 `Clean`。
7. **部署同步**：已執行 `scripts/sync_codex.ps1 -Execute`，完成 Codex、Antigravity 與 Claude Code 三平台同步。

## 異動檔案 (Changed Files)
- **`00_Dev-Control-Center`**：
  - 修改：`AGENTS.md`、`HANDOFF.md`、`IMPROVEMENTS.md`、`README.md`、`configs/AGENTS.md`、`configs/skills-manifest.json`、`configs/skills/accesslint/SKILL.md`、`configs/skills/addyosmani-perf/SKILL.md`、`configs/skills/game-design/SKILL.md`、`configs/skills/lianghao-development/SKILL.md`、`configs/skills/lianghao-development/references/project-governance.md`、`configs/skills/lianghao-development/templates/release-report.md`、`configs/skills/lianghao-development/workflows/release-project.md`、`configs/skills/product-design/SKILL.md`、`configs/skills/webapp-testing/SKILL.md`、`docs/CODEX_SETUP.md`、`docs/DEVELOPMENT_ENVIRONMENT.md`、`docs/DEVELOPMENT_RULES.md`、`docs/PROJECT_ARCHITECTURE_GUIDE.md`、`scripts/setup_developer_tools.ps1`、`scripts/setup_environment_hub.ps1`、`scripts/tests/test_git_status.ps1`、`scripts/tests/test_python_environment_boundaries.py`、`setup_all_envs.ps1`
  - 新增：`configs/skills/product-design/references/design-standards.md`、`configs/skills/product-design/references/ai-interface-patterns.md`
  - 刪除：`.agents/AGENTS.md`
- **其他專案（僅限規則檔）**：
  - `01`、`02`、`04`、`07`、`08`、`09`、`11`：修改 `AGENTS.md`，刪除 `.agents/AGENTS.md` 與 `.gemini/AGENTS.md`
  - `03_Police-Image-Toolkit`：修改 `AGENTS.md`，刪除 `.agents/AGENTS.md`、`.agents/skill.json`、`.gemini/AGENTS.md`
  - `12_ClipMask-AI`、`14_Google-Photos-Takeout-Organizer`：僅修改 `AGENTS.md`

## 刻意未修改 (Do Not Do / Deliberately Omitted)
- 未觸碰 `12_ClipMask-AI` 既有未提交的產品程式碼與測試檔（`clipmask/gui/main_window.py`、`clipmask/gui/styles.py`、`clipmask/gui/timeline.py`、`tests/test_review_workflow.py`、`tests/test_timeline_context.py`）。
- 未自動執行任何 Repository 的 `git commit` 或 `git push`。

## 尚未完成 (Remaining Work)
- **P1 (阻斷/必須)**：無。
- **P2 (重要/當次)**：
  - 由使用者確認後，針對本輪異動的 11 個 Repository 分別檢視與提交（其中 `12_ClipMask-AI` 需注意僅單獨提交 `AGENTS.md`，避免混入既有的 GUI／測試修改）。
- **P3 (改善建議/暫緩)**：無。

## 驗證結果 (Validation)
### 已執行測試與結果
- `scripts/sync_codex.ps1 -Execute` 與 `-CheckOnly`：完成三平台同步，`-CheckOnly` 全數顯示 `Current:`。
- `scripts/tests/test_skill_environment.ps1`：通過 `8 / 8`（失敗 0），含 `verify-agent-environment.ps1` 顯示 `ALL PASS`。
- `scripts/tests/test_v16_acceptance.ps1`：通過 `11 / 11`（失敗 0），含 17 專案清冊掃描與 `build_all_desktop_apps.ps1` 預覽驗證。
- `scripts/tests/test_git_status.ps1`：通過 `6 / 6`（`Clean`、`Modified`、`Ahead`、`Behind`、`Diverged`、`Missing`），ExitCode `0`，且為含 BOM UTF-8。
- `scripts/tests/test_python_environment_boundaries.py`：`Ran 3 tests in 45.821s`（`OK`），ExitCode `0`。
- `setup_all_envs.ps1 -CheckOnly`：ExitCode `0`，5 個現行 Python 專案（`01`、`07`、`12`、`14`、`15`）皆回報 `No broken requirements found.` 與 `就緒`。
- `scripts/setup_developer_tools.ps1 -CheckOnly`：ExitCode `0`，5 個 Python 3.13 環境皆回報就緒；3 支修改後環境 `.ps1` 均驗證為含 BOM UTF-8 且 `Parser::ParseFile` 語法錯誤數 `0`。
- 跨 11 個異動 Repository 及測試檔之 `git diff --check`：全數通過（ExitCode `0`）。

### 尚未驗證項目
- 尚未對變更後的 11 個 Repository 執行 `git commit`／`git push`（需使用者明確授權）。

### 已知風險 (Known Risks)
- `12_ClipMask-AI` 工作目錄同時存在本輪 `AGENTS.md` 修改與既有開發中的 GUI／測試檔案，提交時須指定檔案路徑。

## Git 狀態
- Commit：尚未提交（基底 HEAD：`776c0051ceff43fb1e3c95800b028bec01e82918`）
- Push：否
- Working Tree：Modified
- Branch：main

## 下一步建議動作 (Next Recommended Action)
請檢視各異動 Repository 的變更，確認無誤後分別執行 `git add` 與 `git commit`（`12_ClipMask-AI` 請單獨提交 `AGENTS.md`）。

## 發布狀態 (Release Status)
可交付
