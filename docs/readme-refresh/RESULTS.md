# 各專案 README 更新結果

> 後續修復（2026-10-05）：本文保留 README 更新當時的待辦狀態；09 PaperSwitch 本機入口已修復、建置並驗證，相關 README／交接另已更新，見 [入口修復報告](../paperswitch-launch-repair/RESULTS.md)。

日期：2026-10-05。範圍：GitHub 工作區的 17 個 Repository，共 19 份根目錄 README（包含 05 英文變體及 14 繁體中文變體）。

## 完成內容

各主要 README 補上專案概念、開發原因、典型流程、已知 Bug／限制及去識別問題回報方式。開發原因依既有產品定位及設計整理，不編造作者個人經歷；沒有把尚未重現的問題寫成已確認 Bug，也沒有把既有測試結果當成本輪新測試。

保留原有功能、使用、下載與授權說明，並校正會造成誤操作或誤判的舊內容。05 英文版保留原有使用內容，新增連結指向現行繁體中文維護說明；14 兩份 README 同步補充概念、限制及環境指令。各 Repository 保留／更新共用 HANDOFF，未建立 Agent 個人交接檔。

## 逐專案索引

本表的跨專案連結供本機工作區閱讀；各主要 README 的來源與規則連結維持 Repository 內相對路徑。

| 專案 | README | 本次說明重點 |
|---|---|---|
| 00 開發控制中心 | [README](../../../00_Dev-Control-Center/README.md) | 多專案治理與檢查後執行；管理 16 個其他專案；04 Web／Tauri 現況與實際資料夾名稱。 |
| 01 AG-MONITOR | [README](../../../01_AG-MONITOR-Smart-Video-Screening/README.md) | 監視器候選快篩、CPU 可攜環境；漏抓／誤抓、裸流解碼及停止模式邊界。 |
| 02 基地臺定位 | [README](../../../02_Cell-Tower-Map-Locator/README.md) | 減少座標抄寫與時空比對錯誤；模型交集不是精確 GPS，底圖／定位權限限制。 |
| 03 警用影像工具 | [README](../../../03_Police-Image-Toolkit/README.md) | 報告影像轉換、截圖及切割；編碼器、來源解析度與跨頁檢查。 |
| 04 照片報告 | [README](../../../04_Photo-Report-Generator/README.md) | Word／PDF 製作與 VBA 至 Web／Tauri 的原因；報告壓縮、記憶體與 WebView2。 |
| 05 正式文件 Skill | [README](../../../05_tw-formal-writing/README.md)、[英文變體](../../../05_tw-formal-writing/README_EN.md) | 規範單一來源、AI 草稿核對、建置與選用 PDF 文字擷取限制。 |
| 06 系統優化 | [README](../../../06_System-Optimizer-Tool/README.md) | 集中維護、掃描後確認；工作集數值、快取重建與檔案略過。 |
| 07 行政效能領航員 | [README](../../../07_auto-learning-bot/README.md) | 平臺輔助、embedded 一致入口；AI／共用題庫傳輸、服務費用與時數不保證。 |
| 08 銀行交易解析 | [README](../../../08_Financial-Data-Parser/README.md) | 防止編碼、前導零及長數字失真；來源已遺失資料無法還原，核對帳號及金額。 |
| 09 PaperSwitch | [README](../../../09_PaperSwitch/README.md) | 混合文件工作流、Office 需求；本機啟動驗證待修問題保留。 |
| 10 智慧照片整理 | [README](../../../10_Smart-Photo-Organizer/README.md) | 先索引與審核再處理；完整 3.13 環境、Shell 重跑逾時仍待診斷。 |
| 11 月曆卡片 | [README](../../../11_Calendar-Card-App/README.md) | 本機／GAS 保存邊界；HTTP 啟動、localStorage、語法檢查與端到端測試的差別。 |
| 12 ClipMask | [README](../../../12_ClipMask-AI/README.md) | 本機去識別與人工聽打；漏遮、快速剪輯模式、VAD 與端點觀察。 |
| 13 Project Hub | [README](../../../13_Project-Hub/README.md) | 展示與開發中樞分工；資料／快取一致性、Tag 與 Release 不等同。 |
| 14 Takeout 整理 | [README](../../../14_Google-Photos-Takeout-Organizer/README.md)、[繁體中文](../../../14_Google-Photos-Takeout-Organizer/README.zh-TW.md) | Copy-only 清冊與驗證；日期判讀、容量估算、續作及正確 GUI／CLI 環境流程。 |
| 15 ChainFlow | [README](../../../15_chainflow-inspector/README.md) | 蒐集與研判分離、資料完整性；標籤不等於身分、完整 GUI 測試需隔離歷史資料。 |
| DesktopFramesPlus | [README](../../../DesktopFramesPlus/README.md) | 現行 Data 面板／獨立便箋；兩階段捷徑收納、真實文件參照與不同操作邊界。 |

## 保留的已確認問題與驗證邊界

- **09**：本機 dist/publish 缺少主要 EXE，ValidateOnly 亦受既有來源／產物時間判斷影響。這是前輪已確認問題，本輪未建置或更改啟動器。
- **10**：前輪合成分析首次成功，相同 Shell 流程重跑等候超過 180 秒。原因及正式 GUI 重現仍待確認，測試用 COM 替代讀取器不是產品修復。
- **12**：前輪合成樣本壓制為 89／90 影格，快速剪輯容器約 3.13 秒；只記錄樣本觀察，不推廣為所有影片的結果。上述 10／12 原始證據見 [合成驗收報告](../python-environment-repair/SYNTHETIC-ACCEPTANCE.md)。
- **DesktopFramesPlus**：交接維護紀錄 v2.9.4 與 csproj 內 2.8.1 不同。本輪在文件區分維護紀錄與實際成品識別，未修改版號或重新發布。
- **07**：原始碼共用題庫回報包含課程、題目／選項及 username，AI 呼叫亦涉及外部服務。已移除固定免費額度、固定作答時間與零費用的保證說法；沒有查核目前各服務的實際價格／可用模型。

## 驗證與保護

文件檢查紀錄：[verification.json](verification.json)。檢查根目錄 README 的必要章節、程式區塊、相對連結目標、新增疑似憑證、Git 差異格式，以及分支、HEAD、索引和既有修改的內容保護。套用前 README 原文與 Git 基準保存在 Git 忽略的 artifacts/readme-refresh-baseline。

**最終通過**：17 個 Repository、19 份 README、17 份共用交接及 26 個指令目標；1,081 個既有修改檔案雜湊一致，分支、HEAD 與索引維持基準。根目錄 README 沒有新舊相對連結缺失或差異格式錯誤；索引報告連結另行核對。

驗證工具中途有一次讀取進度停滯，僅停止已核對 PID／腳本的自有驗證程序，改以串流雜湊與逐案進度記錄重跑。中止結果未當成通過；上方數字為正常完成的最後一次結果。工具與原文備份均放在 Git 忽略的 artifacts，不混入產品程式。

沒有執行產品 GUI／單元／遠端 API 測試，沒有安裝套件、修改全域憲法／Skills、變更 PATH、虛擬環境、產品程式或使用者資料。沒有 Commit／Push。外部網址與實際 Release 下載未連線驗證；跨電腦與新發行包仍依各專案發布規範另行驗收。
