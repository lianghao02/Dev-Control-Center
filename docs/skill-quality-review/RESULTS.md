# LiangHao Skill 整體審查與精準強化

研究日期：2026-11-17。中央基準：`826620b12ec969beb17999a493379fe6d641d5b3`，工作分支：`codex/skill-quality-review`。承接同工作階段上一輪未提交的 UI 審查補強，未覆寫未知工作。第三方程式只讀，未安裝 Skill、執行安裝器／Hook／偵測器、登入服務或變更使用者設定。

結論：維持 16 個 Skill 與原 Manifest，補強現有職責，另提供可實際執行的唯讀結構檢查。Impeccable 偵測器保留為需獨立評估的選項；Diagram Design 值得保留外部獨立用途，但此次不全域安裝。

## 1. 研究來源與方法

先讀全域憲法、專案 AGENTS、當前 HANDOFF、IMPROVEMENTS、Manifest 與 16 個 Skill 的名稱／觸發描述；深入五個指定 Skill、相關設計／Windows reference、lianghao-development 執行規範與改善流程，並檢查 project-planning、project-readiness-check、github-workflow、skill-creator 等職責。其他無關 Office／資料處理實作未全面稽核。

八個 GitHub 專案均成功取得原始碼。以下 SHA 是實際 clone 的固定版本；[sources.json](sources.json) 記錄 64 個已閱讀或核對重點段落的檔案路徑、固定網址與 SHA256。這是範圍受限的來源研究，不是第三方全程式安全認證。所有判斷以原始內容為準，不採用 Star 數作決策。

| 專案／固定 Commit | 觸發、工作方式與真正執行能力 | 三平臺適用性、風險與處置 |
|---|---|---|
| [Impeccable](https://github.com/pbakaus/impeccable/tree/d41d9860b0094dcb68030657da63461212835aaa) | `SKILL.md`、`reference/{critique,audit,polish,harden,adapt,hooks}.md` 位於 `.agents/skills/impeccable/`；對前端設計／改善廣泛觸發。critique 結合啟發式與 detector；audit 測技術品質；polish 保留既有設計；harden 涵蓋極端資料／故障；adapt 依裝置／輸入調整。Rust detector 有原始碼與真瀏覽器／CDP 路徑，不只是提示詞。 | README 列 Codex／Antigravity／Claude Code，但 Hook 支援與安裝路徑依 host 不同。launcher 可下載二進位檔；帳號與目錄／遙測可能連網；CI 瀏覽器路徑可停用瀏覽器沙箱。Apache-2.0＋NOTICE。**只改寫適用方法，偵測器獨立評估；Hook 不採用**。 |
| [Taste Skill](https://github.com/Leonxlnx/taste-skill/tree/f6b76575f949707b4e3c37cd86cb44b0b98643e8) | `skills/taste-skill/SKILL.md`：商業／品牌網站、依業務與素材選版面，抽取 palette／type／hero，建置後以 `scripts/consistency.mjs`、`gate.mjs` 與瀏覽器檢查。真的測多尺寸、裁切、對齊、文案、連結、動態等；有 Stop gate 與 waiver，不是一般產品 UX 規範。 | README 提供 Claude／Codex 安裝；Antigravity 可閱讀通用內容，但該 install.sh 不含其部署目標，未實機驗證。Node 22+、Chrome／Edge／Chromium，ffmpeg 選用；新增照片／圖示／Web Fonts 涉及網路。MIT。**借鑑多尺寸與完成判準，不採整套資產、抽籤、強制動畫與 Gate**。 |
| [Diagram Design](https://github.com/cathrynlavery/diagram-design/tree/f6db0decea96de66b901331a0f79a8d4b147ebae) | `skills/diagram-design/SKILL.md` 與 `references/{layout-budget,style-guide}.md`：架構／流程／資料流等 HTML／SVG，語意選型、節點關係、版面預算；`scripts/{self_check,verify_geometry}.py` 能做結構／安全／支援幾何檢查；根目錄 freshness script 對比來源及截圖雜湊。 | 原生 Codex／Claude plugin manifest；Antigravity 可用通用 Skill 格式，未實機驗證。標準庫可跑 self-check；PNG 另需 Python Playwright／瀏覽器。預設 Google Fonts，系統字型與 `--offline` 可減少網路依賴。MIT，內含資產另有 MIT／CC0／OFL。**值得獨立按需使用，不複製進 product-design 或自動加入 Manifest**。 |
| [Hallmark](https://github.com/Nutlope/hallmark/tree/04977e15f3dfd6ee4b74c887dac3eb52665d6c92) | `skills/hallmark/SKILL.md`：新頁面；既有設計須明確點名。`scripts/sloplint.mjs` 有靜態與 render 檢查，Floor／Reflex／Finish 區分規則；theme 與既有設計保留／接線檢查有價值。 | README／package 列 Claude、Codex、Cursor、OpenCode，未明列 Antigravity 實測。Node、render 瀏覽器；可選 Together AI 流程與網路素材；`install-hook.mjs` 可改 `.claude/settings.json`。MIT。**與前兩者高度重疊，不導入另一套 gate／主題系統**。 |
| [Huashu Design](https://github.com/alchaincyf/huashu-design/tree/e8d1148a80d5a281d4247cffe320add3df017928) | 根目錄 `SKILL.md`、`references/critique-guide.md`、`scripts/polish.py`：HTML 原型／投影片／動畫與媒體輸出；明確排除 production Web App／需後端系統。即使風格已定也要求三方向初稿；Python／Node 媒體及畫面檢查不是純提示詞。 | README 列 Claude／Codex 等通用 host，Antigravity 未實測。package 含 playwright／pptxgenjs／pdf-lib；安全文件揭露選用 API、Hook 及部分請求清除 proxy 環境；`fetch_images.py` 可核對。MIT。**多媒體輸出有獨特性，但不屬本次缺口；三方向硬門檻與少設定要求衝突，不採**。 |
| [Awesome Claude Design](https://github.com/rohitg00/awesome-claude-design/tree/7f60ee56b9340f8c2671a08c2d8aab4037546a64) | README、`prompts/README.md`：資源／設計案例／prompt pack／DESIGN.md 索引；目錄中未找到 SKILL.md，不應稱為可安裝的單一 Skill 或自動驗收器。 | 文字可供三平臺參考；列出的外部工具須各自審查，不能將索引的授權視為所有連結內容授權。MIT。**只當案例入口，不安裝、不複製整份索引**。 |
| [Frontend Design](https://github.com/Ilm-Alan/frontend-design/tree/f8966e6cc9b90247aa102d71f7e675ec3462b419) | 根目錄 `SKILL.md`：八種美學 anchor 與具體 palette／字型／材質 token，要求單一方向不混搭。該版本目錄未提供可執行檢查器。 | README 列 Claude／Codex／Gemini CLI；Gemini 不等於 Antigravity 已驗證。部分方向要求全等寬字／強動態，不宜覆蓋系統字型與低資源政策。MIT。**風格選型與 token 已有，不新增同類 Skill**。 |
| [Claude Artisan](https://github.com/ara-mkr/claude-artisan/tree/ae6d3add319e7be885f8b02fc0feec8085b0bfc1) | `design-language/SKILL.md`：指定風格／模糊氛圍轉為 token、逐元件套用；`scripts/consistency_audit.py` 是標準庫 regex 漂移檢查，`contrast_check.py` 有色彩數學，不能理解完整 CSS cascade／實際背景。 | Claude 原生、其他可讀格式之 Agent 原則可參考，Codex／Antigravity 未實測。檢查腳本以本機檔案與標準庫為主；產出資產仍需核對字型來源。MIT。**style-specific 可及性與元件盤點可借鑑；不導入 199 套規格或第二套主題治理**。 |

## 2. 三個優先專案功能比較與成本

I＝Impeccable 的 `.agents/skills/impeccable/`；T＝Taste 的 `skills/taste-skill/`；D＝Diagram 的 `skills/diagram-design/`。完整固定網址見來源索引。成本為程式／流程的質性判斷，**沒有執行第三方效能或 Token benchmark**。

| 第三方功能及來源檔案 | 本庫既有對應／完整度 | 分類與實際處置 | 執行時間、Token、維護／安全影響 |
|---|---|---|---|
| I `reference/critique.md`：獨立設計判斷＋偵測證據、分級 | product-design／lianghao-development 已有設計原則及三級分類；具體證據不足 | **部分具備，適合補強**：改寫基線、已重現／疑點／建議及最小修正；不引進第二套 P0–P3／十項總分 | 小任務用 Quick；不固定雙 Agent，不強制長篇評分；降低預期載入成本，未量測節省量 |
| I `reference/audit.md`：技術品質／a11y／效能 | accesslint、webapp-testing、addyosmani-perf 已分工 | **已具備，不需另建**：維持各自觸發，補工具缺席及限制記錄 | 避免每次 UI 任務都跑全合規／效能工具；避免重複報告 |
| I `reference/polish.md`：元件系統漂移與完整路徑 | product-design 有 token／元件狀態；跨畫面比較不足 | **部分具備**：比較同角色元件，修既有 token／共用元件的最小範圍 | 增加必要操作與畫面比對，不一律抽象元件或換框架 |
| I `reference/harden.md`：長文字、故障、重複操作與中斷 | 八狀態、資料安全與 Windows 取消機制已存在 | **部分具備**：依受影響變更補重複送出／失敗後再操作；沿用既有狀態清單 | 只測與變更有關的極端條件，避免全案例常駐載入 |
| I `reference/adapt.md`、T `scripts/consistency.mjs`：跨尺寸與互動 | webapp-testing 有瀏覽器順序，取樣條件不足 | **部分具備**：窄／中／寬與斷點兩側、200% 真縮放區分、觸控證據區分 | 有實際瀏覽器成本，依支援範圍裁剪；不強制同一欄數或導覽樣式 |
| I `crates/detect/src/cli.rs`、`crates/browser/src/lib.rs`：原始碼、URL／CDP、before／kept 接線盤點 | 無同等全套引擎；既有 Browser 可完成部分操作 | **具有可執行工具，需獨立評估**：保留選項與接線盤點方法，不執行／vendor 引擎 | source pattern、static HTML、render 覆蓋不同；登入後可有統計上傳、CI 分支停用沙箱；不得當作純離線程式 |
| I launcher／`reference/hooks.md`／`.codex/hooks.json` | 本庫以按需 Skill 與明確部署預覽治理，沒有設計 Hook | **與環境衝突，不採用**：不安裝 Hook、不停用信任／沙箱；只保留審查後手動評估途徑 | 每次編輯／結束掃描有額外耗時與輸出；Claude Hook 可能不經模型命令核准，不能因本次研究而啟用 |
| T SKILL、`scripts/gate.mjs`：設計完成標準與真瀏覽器 Gate | 工程停止條件及 Web 證據已有，缺 UI 具體複驗 | **部分具備／重複不導入**：沿用三級分類與相同條件複驗，結果有效時不重掃 | gate 自述完整 CPU Chrome 掃描需數分鐘；不為可主觀美化的 FAIL 無限重跑 |
| T SKILL 的 deal／素材與強制 hero／moments | 既有自主風格、指定風格優先、系統字型政策較適合工具 | **與環境衝突，不採用**：借鑑語意與節奏，不導入抽籤、強制動態與網路素材 | 額外素材／GPU／字型／維護成本，並可能偏離行政與離線工具目的 |
| D SKILL、`references/layout-budget.md`：架構／流程／資料流 HTML／SVG | product-design 只有一般可讀性；沒有完整製圖工法 | **尚未具備，值得新增能力**：以獨立外部 Skill 按需保留，這次不新增共用 Skill | 製圖時才讀相關類型；不把 50 類規格塞入每次 UI context；固定節點上限不套通用 UI |
| D `scripts/{self_check,verify_geometry}.py`、根 `scripts/verify-screenshot-freshness.py` | 無同等 SVG 幾何與來源雜湊工具 | **具有可執行工具，需獨立評估**：確認真程式能力；不宣稱提示詞等於已實作 | self-check 標準庫、幾何覆蓋有限；PNG 另有 Playwright／browser；不一律增依賴 |

## 3. 現有職責、重複、缺口及矛盾處置

- **職責保留**：lianghao-development 管治理／資料安全／停止條件；product-design 管設計與審查方法；webapp-testing 管 Web 實際證據；accesslint 管正式 a11y 專項；windows-tool-ux 管桌面平台。game-design 僅遊戲／HUD；效能走 addyosmani-perf；PR 前走 project-readiness-check，不另造總控 Skill。
- **可保留的重疊**：入口摘要與按需 reference、一般鍵盤原則與正式 a11y 檢查不是相同執行流程；不因字詞重疊刪掉必要入口。
- **已修正的矛盾**：product-design 允許 Quick 局部修復，但 agent-execution 原觸發廣至任何 UI／響應式改善仍要求案例比較。現收斂為新 UI／整體改版／重大流程；局部調整沿用現有模式。
- **已修正的過度觸發**：project-planning description 原含「需求仍模糊的工作」，與內文純產品探索唯讀分流不一致；現在只涵蓋需保存實作進度的工作。accesslint description 原稱掃描「工具」，現在說清楚是流程與離線範例，沒有內附引擎。
- **已移除的無依據硬門檻**：30% 使用者／30 秒即隱藏功能，以及四層資訊必須固定排列。改成依核心任務與證據判斷；導覽 5–7 作分組起點而非硬湊數。具體效益是減少 Agent 在缺少使用資料時擅自改流程，不是承諾轉換率提升。
- **刻意不擴大**：原有八狀態、字級／間距／對比與低資源要求已足夠，未整套重寫；未將一般工具一律升格 WCAG 全掃描，也未因風格工具要求外部字型。

## 4. 實際修改及可執行能力

此 PR 包含上一輪尚未提交的修改，以下列最終狀態與原因。

| 檔案（`configs/skills/` 下除另註） | 最終變更與效益 |
|---|---|
| `product-design/SKILL.md`、`references/design-standards.md` | 保留 Quick／Full，連接按需審查／選用工具；移除無量測依據的功能隱藏與固定排列規則，修正入口節次 |
| 新 `product-design/references/ui-review.md` | 同條件基線、同角色元件、證據與三級分類、按鈕／表單／下載接線盤點、複驗與停止；不再只回「不夠美觀」 |
| 新 `product-design/references/design-tools.md` | 只有明確 detector／製圖任務才讀；說明 Impeccable 安全及 Diagram 獨立用途，不執行安裝 |
| `webapp-testing/SKILL.md` | 取樣、縮放／觸控區分、長頁 lazy 圖片的逾時防線、條件相同之前後比較、與變更相關的重複送出／復原 |
| `accesslint/SKILL.md` | 真正工具需求、範例保留 selector／failureSummary／incomplete；零違規不代表全面合規；修正 data-safety 指向 |
| `windows-tool-ux/SKILL.md`、既有 `references/windows-compatibility.md`、`checklists/windows-compatibility.md`、`workflows/review-desktop-ux.md` | 只在該領域補雙系統實機矩陣、API 替代、技術棧分流與設定調整邊界 |
| `lianghao-development/references/agent-execution.md`、`project-planning/SKILL.md` | 收斂局部 UI 案例研究與純探索觸發，減少不必要的研究／文件 |
| `skill-creator/SKILL.md` | 維護時連接中央唯讀檢查器，不改三平臺分流 |
| 新 `scripts/check_skill_contracts.py`、`scripts/tests/test_skill_contracts.py` | **真正執行程式**：標準庫檢查名稱／有限 frontmatter 格式、Manifest、Markdown／具體行內路徑及三平臺來源數；6 組隔離測試驗證錯誤能被攔截 |
| `docs/skill-quality-review/{RESULTS.md,sources.json}`、`HANDOFF.md` | 本次證據與交接，不將第三方全文放入 Skill |

只有最後的 Python 檢查器新增了實際自動化；其餘主要是提示詞／流程補強。截圖、axe、像素差異、SVG 幾何、效能及 Windows 驗收都仍需對應工具或實機。本輪沒有新增自動視覺偵測引擎。

## 5. 初次驗證結果與處理方式前後比較

後續複審修正與補測見第 8 節。

| 驗證 | 實際結果／限制 |
|---|---|
| `python scripts/check_skill_contracts.py` | 通過：16 個 Skill、9 個 Markdown 相對連結、27 個具體行內引用、46 個部署目標（15 shared×3＋1 Antigravity-only）；不是動態部署結果 |
| `python -m unittest discover -s scripts/tests -p test_skill_contracts.py -v` | 6 組通過：唯讀性／共用目標、重複分流、未分流目錄、重複／未知／空 frontmatter 與名稱不符、遺失／越界連結、有效引用及 code fence 排除 |
| 完整 YAML 解析 | 使用環境既有 PyYAML 的重複鍵檢查 Loader，16 組 frontmatter 與 3 個 agents YAML 通過；新檢查器不冒充通用 YAML 解析器，本庫未新增 PyYAML 相依 |
| `git diff --check`、引用與來源 | 通過；sources.json 的固定 SHA／檔案雜湊與本地研究副本逐一核對。行內路徑檢查只接受明確檔案路徑；模板／外部／動態範例不當成本地檔案 |
| 部署規則 | Manifest、全域憲法、`scripts/sync_codex.ps1`／resolver／既有部署測試未修改；共用 Skill 仍遞迴複製到三平臺，Antigravity-only 的 skill-creator 保留，不將其新增為 Claude 同名 Skill |
| `powershell -ExecutionPolicy Bypass -File scripts/sync_codex.ps1 -CheckOnly` | **未完成**：回傳 127，雲端無 powershell／pwsh。不改腳本繞過，也不將 Python 來源檢查當作部署成功 |
| 本輪瀏覽器啟動 | 已嘗試系統 Chromium＋既有 Playwright，明確保持 `chromiumSandbox:true`；初次 socket 權限不足，提供網路權限後仍因 SUID sandbox helper 設定不正確而中止。未修改系統權限、未加 `--no-sandbox` 重試；**本輪新畫面驗收未完成** |
| 上一輪歷史證據 | 同版本 Project-Hub 五尺寸搜尋／分類／JSON 備援測試曾執行；保留為歷史，不冒稱符合本輪沙箱要求的新實測。本輪未重跑其舊腳本、未修改其他 Repository 產品程式 |

代表情境使用既有 `lianghao02/Project-Hub@44be7b0fc0976cb8c29d677dc6227e5c1c3c7e1f` 的純 HTML／CSS／JS 作品列表；已核對 `index.html` 的 768 breakpoint、分類列、搜尋欄與 `assets/js/main.js` 的搜尋／備援路徑。以下是**依條文進行的處理方式追蹤**，不是多模型盲測，也不是產品 UI 改版成效。

| 相同任務輸入 | main 原規範的處理風險／不足 | 本 PR 規範的可驗收處理 |
|---|---|---|
| 只修 390px 搜尋欄與分類列間距 | Quick 與「UI 改善先比較案例」可能同時命中 | Quick；沿用 token，不開三方案或規劃檔；檢查 390、768 及相關斷點兩側，列出未測真縮放／觸控 |
| 認為低頻功能應收起 | 未量測亦可能套 30%／30 秒，改動導覽 | 未知使用率明列未知；先證明核心任務入口與復原仍可達，不擅自隱藏 |
| 修正卡片按鈕外觀 | 有功能相容原則，缺接線盤點格式 | 保存連結／事件／下載目的地，改後重走同一流程，不只比截圖 |
| 正式公開站要求無障礙，卻沒有 axe | description 容易被當成已裝工具；範例多留數量 | 先檢查引擎；缺席標略過，人工檢查分開；若可掃，保留 selector／incomplete，不稱全面合規 |
| 要產出架構／資料流 HTML／SVG | 一般 UI 規範缺完整製圖路徑 | 少量沿用 Mermaid；複雜自含圖才讀選用工具 reference，評估外部 Diagram，不自動安裝 |
| 網頁版可用，要驗 WPF／Tauri／Python 發布包 | 桌面總原則存在，但缺分系統證據與具體架構提示 | 依同一 Windows 清單分別記錄兩系統，依實際技術棧驗 .NET／WebView2／embedded，不用 Web 通過代替 |

這些追蹤能證明規範的路徑已收斂，不能證明 Codex／Antigravity／Claude Code 實際選取率、返工次數或 Token 已下降。Token／耗時效益尚未量測；新增的兩份按需設計 reference 不在一般 UI 任務一律載入，維持入口精簡。

## 6. 本機部署與 Windows 10／11 驗收

1. 在獨立分支審閱 PR，先確認本機無未知未提交修改；不要覆寫、強制更新或直接合併 main。
2. 在控制中心根目錄先跑 `python scripts/check_skill_contracts.py` 及上述 unittest。新工具只讀且不安裝依賴；完整 YAML 用已有解析器補驗。
3. 執行 `powershell -ExecutionPolicy Bypass -File scripts\sync_codex.ps1 -CheckOnly`，檢查共用三平臺與 Antigravity-only 分流。Unmanaged／Modified 先釐清，不直接加 -Force。
4. **本次只授權研究、修改、工作分支與 PR，不含本機部署**。取得部署授權後才跑原同步腳本 `-Execute`，再跑 `-CheckOnly` 與 `powershell -ExecutionPolicy Bypass -File scripts\tests\test_skill_environment.ps1`，保存來源／目標與測試證據。
5. 三平臺各用一個 Quick 局部修復、純產品探索與正式 a11y 任務檢查載入邊界；確認新 reference 依需要可讀，未把純探索變成寫計畫、未把內部小工具變成全面 WCAG 掃描。這部分雲端未測。
6. Windows 實機只沿用 [windows-tool-ux 相容性清單](../../configs/skills/windows-tool-ux/checklists/windows-compatibility.md)，不另寫第三份支援政策。兩系統各測同一包：實機啟動／核心功能、繁中文字型／長文字、100%／125%／150% DPI 與視窗縮放、中文與空白路徑、一般權限、乾淨環境免安裝、離線／低資源及 Win11 專屬功能替代（適用時）。WPF、Tauri、Python GUI、純 Web 依清單技術列分流；無桌面相依的 Web 不強制桌面專項。

**Windows 10 與 Windows 11 以上項目均待本機驗收，沒有任一方已通過的宣稱。** 對不支援的功能須列技術限制、可行替代與影響，不自行取消任何系統支援。顯示設定調整先取得允許，結束還原。

## 7. 不採用項目與未解決風險

- 不全面安裝八套 Skill：重疊設計／token／反制式規則會放大衝突、載入成本與更新責任。
- 不採自動 Hook／Stop Gate：可能在每次編輯與結束時執行下載／掃描，host 信任機制不同，不符合本次授權。
- 不採必做三方向初稿、固定主題抽籤、強制 hero／動畫、風格硬綁外部字型：對局部修復、離線行政工具與明確風格需求可能增加返工。
- 不將 SVG 固定節點預算、品牌網站字數／版面比例或主觀總分設為全域發布門檻。
- 不認定 Impeccable 已可安全離線採用：固定版本下仍需在不降低沙箱、隔離帳號與禁止外傳的環境做實際偵測器試驗；本輪只完成來源評估，沒有動態誤報率／耗時資料。
- Diagram 獨立使用有價值，但需明確製圖需求才啟用；預設字型連網、PNG 依賴、profile 寫入與升版行為須另驗。此次沒有安裝或修改全域 style guide。
- 規範衝突經人工追蹤並收斂，不等於長期多平臺行為已保證。PowerShell 部署、本輪新 Browser 驗收、Windows 實機與輔助科技仍未通過；PR 應以 Draft 供審查，不自動合併。

## 8. PR 複審修正與補測

- 結構檢查新增參考式連結、常用 Markdown 章節錨點及平台分流驗證。共用 Skill 引用未部署到其中任一平台的檔案時會失敗。8 組 Python 測試通過。
- 同步與部署驗證使用同一份分流計畫。Linux PowerShell 7.4.22 在暫存設定檔執行 `-CheckOnly` 列出 50 個項目且保持唯讀。8 組環境測試通過，確認 46 個 Skill 目標內容、AGY 專用分流，以及 Codex 缺檔、AGY 參考檔過期都會被攔下。Windows PowerShell 5.1、本機實際部署與 Agent 載入仍待驗證。
- 交付檢查補上 `git diff --cached --check`，推送或開 PR 時另檢查相對實際目標分支的提交差異。隔離 Git 測試重現一般差異檢查漏掉已暫存尾端空白。
- 無障礙範例等待目標狀態再掃描，明確指定 axe 的 WCAG 標籤。3 個模擬情境通過，涵蓋就緒後掃描、等待逾時與引擎缺少標籤。瀏覽器實際掃描仍待驗證。
- 局部 Web 修正依影響取樣，跨頁與版面變更保留合適尺寸和縮放驗收。明確但跨模組或具相容性風險的 Bug 依規劃條件判斷。Windows 正式與 Portable 發布流程均指向既有 Windows 10／11 清單。
