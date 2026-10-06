# LiangHao Dev Control Center (開發控制中心)

本 Repository 為 LiangHao 開發環境與多專案治理的中央控制中心。保存全域開發憲法 v8.5、LiangHao 四大核心共用技能庫（Shared Skill Pack v2）、16 個開發 Repository 清單，以及 Windows 環境重建與一鍵自癒佈置腳本。目前版本為 **v1.8.0**。

> 🌐 **公開專案展示入口**：所有作品集、Demo 與 GitHub Pages 頁面已獨立遷移至 [lianghao02/Project-Hub](https://github.com/lianghao02/Project-Hub)（展示站：[https://lianghao02.github.io/Project-Hub/](https://lianghao02.github.io/Project-Hub/)）。中央控制中心專注於環境與治理，不再兼任展示網站。

## 專案概念與開發原因

開發中樞將多個 Repository 的環境檢查、啟動入口、Git 狀態與 Agent 規範集中管理。開發背景是跨專案切換時，工具版本、操作步驟與交接文件容易分散，造成重複設定或誤操作。

它面向本機維護者，重點是先檢查、顯示差異，再依明確模式執行。全域憲法與共用 Skills 以 `configs/` 為唯一維護來源；對外成果展示交由 Project Hub，不在此混入展示網站功能。管理範圍為 16 個其他專案，連同本中樞共 17 個 Repository。

**典型流程**：查看各專案狀態 → 唯讀環境／設定檢查 → 處理確認過的差異 → 個別專案驗證。

## 技術架構現況（2026-09-08）

- 工作區主力技術依專案用途分流：AI 鑑識與行政自動化維持 Python、免安裝資料工具維持純 Web、Windows 原生工具採 C#／.NET 8／WPF。
- `03_Police-Image-Toolkit`、`06_System-Optimizer-Tool` 與 `09_PaperSwitch` 已完成 C#／.NET 8／WPF 遷移；舊版分別封存於 `legacy_web/` 與 `legacy-python/`，供回歸比對與備援。
- `04_Photo-Report-Generator` 採純前端 Web SPA 與 Tauri 2 桌面封裝，不依賴 VBA 或 Microsoft Office；其他專案的技術與遷移邊界以各自 README 為準。
- 專案入口網站已獨立為 `13_Project-Hub`，採純靜態 Web 與 GitHub Pages 託管。
- 最新納入資金流向鑑識 `15_chainflow-inspector` 與桌面分類面板 `DesktopFramesPlus`，總計管理 16 個其他 Repository。

## 下載、需求與執行入口

- **用途**：集中管理專案清單、Git 同步、Codex／Antigravity 規則，以及仍採 Python 的專案可攜環境。
- **必要軟體**：Windows 10/11、Git for Windows；建議使用 PowerShell 7，未安裝時各入口會自動退回 Windows PowerShell 5.1。管理功能本身不要求先安裝 Python。
- **下載**：`git clone https://github.com/lianghao02/Dev-Control-Center.git 00_Dev-Control-Center`。
- **主要入口**：一般使用者直接雙擊 `0_開發中樞.bat` 進入終端選單；`1_`～`3_` 保留為直接快捷入口，`0_控制中心_手帳儀表板.bat` 則保留為選用 GUI 儀表板。進階使用者可執行 `scripts/` 下對應 PowerShell 腳本。
- **網路需求**：Clone、Pull、Push 與首次下載 Python 可攜核心時需要網路；若 `downloads/` 已有安裝母檔，Python 環境可離線建置。
- **打包方式**：本專案是管理腳本集合，不需編譯或安裝；備份時保留完整資料夾即可。

## 雙擊快捷捷徑 (One-Click Flagship Batch Tools)

在 `00_Dev-Control-Center` 根目錄提供精煉的批次入口；BAT 只負責定位 PowerShell 與啟動腳本，Git、建置、環境與 Agent 邏輯皆集中於 PowerShell：

0. 🧭 **`0_開發中樞.bat`**（日常主入口）：
   - 開啟 `scripts\dev-hub.ps1` 終端選單，可快速檢查、執行安全同步、建置、**檢查／同步 Agent 技能庫與憲法**、檢查環境或開啟 GUI。
   - 選單項目 **`[4] 檢查 / 同步 Agent 設定`** 支援一鍵執行：
     - `1`：**AgentCheck（唯讀檢查）**，比對本機與雙平台（Codex / Antigravity）的技能目錄與雜湊一致性。
     - `2`：**AgentSync（正式同步）**，一鍵將全域憲法與 4 大共用 Skill 鏡像推播至雙平台原生設定目錄。
   - 優先使用 PowerShell 7，未安裝時自動退回 Windows PowerShell 5.1；以 BAT 自身位置推導路徑，不依賴固定磁碟代號或目前工作目錄。
   - PowerShell 7 的唯讀快速掃描採最多 4 條平行工作；Windows PowerShell 5.1 維持序列掃描，兩者均使用相同安全狀態分類。

0. 📔 **`0_控制中心_手帳儀表板.bat`**（選用 GUI）：
   - 啟動後立即顯示儀表板，預設維持「尚未掃描」；使用者可按 Level 1／2／3 按鈕才執行所需檢查。
   - 保留 Repository 視覺總覽、同步、桌面建置、Agent、環境與日誌等進階操作。

1. 🌟 **`1_全專案智慧同步中樞.bat`** (日常開發主力)：
   - 雙擊即時掃描 16 個專案之本機與雲端狀態。
   - **`[1] ⚡ 智慧全自動同步`**：只拉取工作目錄乾淨的版本庫，分發 AI 設定後只推送既有提交；未提交修改一律保留並提示逐案檢視。
   - 支援 `main` 與 `master`，並提供 `[2]` 僅拉取更新、`[3]` 僅推送既有提交、`[4]` 僅分發 AI 憲法與 Skills。

2. 🌟 **`2_建置所有桌面應用程式.bat`** (版本建置主力)：
   - 一鍵集中編譯 6 個桌面／可攜式應用程式（`01`, `03`, `04`, `06`, `07`, `09`）。
   - 嚴格分離「建置」與「發布（Release）」；GUI 與批次檔皆提供安全建置與即時輸出檢視。

3. 🌟 **`3_環境建置與工具安裝.bat`** (環境初始化與維護)：
   - **`[1]`** 一鍵為 Python 專案建置環境：`01`、`07` 維持 embedded；`10`、`12`、`15` 使用 3.13 `.venv`；`14` 僅檢查既有 `.venv`。
   - **`[2]`** 檢測並補齊核心 Git、GitHub CLI、Python 3.13 與 .NET 8；Node.js 為建議元件，Rust、Playwright 與 Tauri 前置元件依實際需求安裝。

成品維持在各專案既有的發布目錄；AG-MONITOR 完整 CPU 可攜包輸出至 `01_AG-MONITOR-Smart-Video-Screening\dist\`。若只想確認路徑與發布腳本是否齊全，可省略 `-Execute` 進行預覽。

## 新電腦快速開始

先安裝 Git for Windows，再於 PowerShell 執行：

```powershell
New-Item -ItemType Directory -Path 'C:\Development\GitHub' -Force
git clone https://github.com/lianghao02/Dev-Control-Center.git 'C:\Development\GitHub\00_Dev-Control-Center'

# 預覽，不修改檔案
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Development\GitHub\00_Dev-Control-Center\scripts\sync_projects.ps1'

# 正式複製／更新專案並部署 Codex、Antigravity 規則
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\Development\GitHub\00_Dev-Control-Center\scripts\sync_projects.ps1' -Execute
```

腳本會依 [development-repositories.json](development-repositories.json) 處理 16 個 Repository。遇到既有未提交變更時會略過；遇到分支分歧時會繼續檢查其餘專案並於結尾列出，不會自動刪除任何本機資料夾，也不會強制覆蓋 Git 歷史。

## Agent 設定與治理機制

- **全域規則唯一編輯源**：[configs/AGENTS.md](configs/AGENTS.md)（部署至各 Agent 環境之全域開發憲法 v8.5）
- **共用技能庫唯一編輯源**：`configs/skills/`（Canonical 來源目錄，嚴禁反向覆蓋）
- **分流部署定義檔**：[configs/skills-manifest.json](configs/skills-manifest.json)（定義雙平台共用與專用技能）
- **跨專案改善事項總表**：[IMPROVEMENTS.md](IMPROVEMENTS.md)（所有專案已確認改善與待辦唯一彙整表）
- **當前交接狀態斷點**：[HANDOFF.md](HANDOFF.md)（本專案之工作交接與中斷紀錄）

### LiangHao 四大核心共用技能庫 (Shared Skill Pack v2)

本開發生態系統採用模組化 Skill 架構，提供判斷框架與安全預設，所有技能均為 Stable 維護狀態：

1. **`lianghao-development` (v1.0.0)**：跨 Agent 軟體工程與專案治理標準（AUDIT、EVALUATE、FIX、IMPROVE、RELEASE、HANDOFF 與發布門檻）。
2. **`taiwan-office-automation` (v1.0.0)**：臺灣公務行政與 Office/PDF 自動化（民國日期、Excel 長帳號/前導零防破壞、Word/PDF 雙軌擷取、公文文風）。
3. **`safe-data-processing` (v1.0.0)**：使用者原始資產安全處理（Inspect-First 盤點、Copy 優先、Dry Run 模擬預覽、來源模式驗收、隔離審查概念）。
4. **`windows-tool-ux` (v1.0.0)**：Windows 桌面工具與使用者體驗（Win10/11 雙相容、Portable 免安裝架構、零假死防凍結設計、實測導向非同步）。

### 雙平台原生目錄與單向同步機制

`scripts/sync_codex.ps1` 執行時，會將中央設定單向鏡像部署至雙平台原生目錄：

- **全域憲法** ➜ `%USERPROFILE%\.codex\AGENTS.md` 與 `%USERPROFILE%\.gemini\config\AGENTS.md`
- **Codex 技能目錄** ➜ `%USERPROFILE%\.agents\skills\<skill-name>`
- **Antigravity 技能目錄** ➜ `%USERPROFILE%\.gemini\config\skills\<skill-name>`

外圍輔助技能亦由 `configs/skills-manifest.json` 統一管理分流（如 `project-readiness-check`、`webapp-testing`、`document-to-markdown` 等 `shared` 技能，以及 Antigravity 專用的 `skill-creator`）。`%USERPROFILE%\.codex\skills` 的個人獨立 Skill 與系統原生 Skill 均不會被覆寫。

### 單獨檢查或同步指令

```powershell
# 唯讀檢查（比對本機與雙平台目錄狀態與 Hash）
.\scripts\sync_codex.ps1 -CheckOnly
# 或透過 dev-hub 執行
.\scripts\dev-hub.ps1 -Action AgentCheck

# 正式同步（將全域憲法與所有共用 Skill 推播至雙平台）
.\scripts\sync_codex.ps1 -Execute
# 或透過 dev-hub 執行
.\scripts\dev-hub.ps1 -Action AgentSync

# 僅在強制覆蓋目標設定時才使用 Force
.\scripts\sync_codex.ps1 -Execute -Force
```

## 本機專屬資料

以下資料不得提交至 GitHub，必須在每台電腦個別設定：

- `.env`、API Key、Token、密碼
- Python `.venv`
- `node_modules`
- 瀏覽器登入狀態與 Cookie
- 大型模型快取、pip 快取、應用程式快取

各 Python 專案應依自己的 `requirements.txt` 或 `pyproject.toml` 重新建立虛擬環境，不得直接複製其他電腦的 `.venv`。

## 安全設計

- 同步專案前先檢查 Git 狀態；有未提交變更時直接略過。
- 只允許 `pull --ff-only`，不自動合併、rebase 或 force push。
- 同步中樞將每個版本庫明確分為 `Synced`、`Modified`、`Ahead`、`Behind`、`Diverged`、`Error` 或 `Missing`；只有 `Ahead` 會進入「推送既有提交」流程，該流程不會執行 `git add` 或 `git commit`。
- 產生 JSON 與部署文件時使用 UTF-8 無 BOM，避免 PowerShell 5.1 編碼差異。
- 部署前保留可復原備份，並限制備份數量，避免長期累積。

## 路徑架構

- 實體開發路徑：`D:\Development\GitHub`
- 舊工具相容路徑：`C:\Users\<使用者名稱>\Documents\GitHub`

Junction 屬於選用的本機相容設定，不儲存在 Git 中。詳細規範請參閱 [docs/DEVELOPMENT_ENVIRONMENT.md](docs/DEVELOPMENT_ENVIRONMENT.md)。

環境整理與驗證記錄見 [Python 環境修復](docs/python-environment-repair/RESULTS.md)。`setup_all_envs.ps1 -CheckOnly` 為唯讀檢查；`-Force` 僅對 10／12／15 重新套用需求，不刪除環境。`sync_codex.ps1 -CheckOnly -SkipMcpConfig` 可限縮檢查至憲法與 Skills，確認後才使用 `-Execute -SkipMcpConfig`。

## 已知 Bug、限制與疑難排解

以下區分已確認問題、功能限制及待驗證項目；歷史修正不代表舊發行包已自動更新，也不代表本次文件更新重新完成所有功能測試。

| 狀態 | 情境 | 處理方式 |
|---|---|---|
| 操作限制 | 工作目錄有未提交修改，或分支出現分歧。 | 先閱讀差異；安全同步不代表可以自動丟棄修改或代為提交。 |
| 環境限制 | Git、PowerShell 或專案所需 Runtime 缺失。 | 以各工具的檢查模式確認，再處理缺失項目；不要僅為使用中樞而安裝所有選用工具。 |
| 待驗證 | 個別專案已有功能問題，或不同電腦尚未完成啟動驗證。 | 中樞的檢查通過不等於所有應用程式功能通過；查看各專案 README 與 HANDOFF。 |

歷史修正包含 PowerShell 編碼與 Git 狀態辨識等維護問題，詳見 [CHANGELOG.md](CHANGELOG.md)。目前環境與目錄整理證據分別見 [環境修復報告](docs/python-environment-repair/RESULTS.md)、[目錄整理報告](docs/project-layout/RESULTS.md)。

### 問題回報

請提供使用版本／啟動方式、作業系統與相關環境、重現步驟、預期及實際結果，以及去識別的錯誤訊息或最小樣本。先保留現場與來源資料；不要附真實案件、完整帳號、密碼、Token 或 API Key。版本修正以對應原始碼與發行包為準。
