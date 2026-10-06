# PaperSwitch：辦公室文件加密環境診斷

日期：2026-10-06。承接 [代表性驗收](RESULTS.md)，本輪僅查詢保護元件、補充隔離對照與修訂文件，未改產品程式或系統保護。

## 結論與證據邊界

依目前證據，將 Office 輸出 IGEF 以**辦公室文件加密環境限制**追蹤。沒有已確認的 PaperSwitch 演算法缺陷，保留原有等待／拒絕機制；正常 Office 轉 PDF 仍未通過，不能因找到保護軟體就改標成驗收完成。

| 分類 | 發現 |
|---|---|
| 已確認 | 前輪正式 C# COM 服務產生的 Word／Excel／PowerPoint 輸出均為 `IGEF 02 00 00 00`，不是 `%PDF`；標準 PDF 合併／旋轉／分頁通過。 |
| 已確認 | `GoPatrolAgentService` 正在執行；其 `GopProcFilterDriver`、`GopProtectDrv` 與 `InjectSys` 驅動正在執行。 |
| 已確認 | 三種 Office 有 `GOP.Connect.1`／`TFGPlus.Connect.1` 外掛註冊；對應 DLL 版本為 1.0.0.14／1.0.1.8，數位簽章均有效，簽署者為 I-PRESS INC.。DLL 公司欄位為 Secward。 |
| 已確認 | TFG 目錄存在 InfoGuard 元件；`SecuFileX64` 驅動目前停止。不能把目錄存在或外掛註冊當作全部元件正在載入。 |
| 推論 | 使用者補充辦公室文件加密的情境，與本機正在執行的 GoPatrol 保護及 IGEF 輸出吻合。依環境限制處理較合理，尚未取得管理端規則或加密事件來歸因到單一外掛。 |
| 尚待驗證 | 管理端允許的 PDF 產出／讀取流程，以及三種 Office 的可讀標準 PDF 驗收。 |

廠商說明 GoPatrol 可保護 Office／PDF，並提供申請解密流程；盔甲方案說明可依應用程式自動加密。這支持環境限制的判斷，**不是 IGEF 檔頭規格或本機特定規則的直接證明**。來源：[官方功能介紹](https://www.gopatrol.net/functions)、[官方盔甲方案](https://www.secward.com/planarmor)。

## 補充對照的實際結果

另以 Windows PowerShell 5.1 的獨立 Word COM 對照，只建立新的合成 RTF，不使用個人 Office 文件或 PaperSwitch 服務。第一次在啟動 COM 前，因測試主機無法取得 `Get-FileHash` 而失敗；改用 .NET 雜湊後，對照在 75 秒內未完成，未取得輸出。因此**不能宣稱已證明獨立 Word 匯出同樣為 IGEF**。

逾時時只停止本輪測試宿主。另核對本輪建立的隱藏 Word PID 26184、建立時間及空白視窗標題後回收；原先 Office 程序為 0，結束後仍為 0。前輪已通過的 C# COM 清理不因這個不同宿主的失敗而改寫；本次逾時原因未確認，不列為產品 Bug。

證據位於 Git 忽略的 `artifacts/igef-diagnosis-c41edce4bf924c688f6658cac7f0b18c/`：`protection-inventory.json`、`timeout-result.json`、`owned-office-timeout.json`、前後 Git／保護雜湊。測試宿主與失敗記錄保留供查核；不再擴大重跑。

## 最小影響處理方式

1. 目前需要編排文件時，使用單位既有申請／核准流程取得 PaperSwitch 可讀的標準 PDF，再匯入。更換資料夾或延長等待不等於取得授權或完成解密。
2. 若要在受控電腦直接轉換 Office，由管理端確認 PaperSwitch 的核准使用方式：Office 產出的暫存 PDF 是否允許供此工具讀取，以及應採哪個官方流程。先以合成文件確認，不放寬整個工作區或全部 PDF 的保護。
3. 流程確認後，使用既有 `test_office_acceptance.ps1` 再驗收三種 Office。須同時滿足 `ReadableOfficePdfs = 3`、`BlockedOfficePdfs = 0`、標準 PDF 功能通過、來源雜湊一致及 Office 殘留 0。腳本退出 0 本身不代表正常 Office 轉檔通過。

供管理端核對的說明（本輪沒有傳送）：

> PaperSwitch 透過 Microsoft Office COM 匯出 PDF，再以一般 PDF 函式庫讀取與編排。本機三種合成 Office 輸出皆為 IGEF，工具依既有防護拒絕載入。請確認單位允許的標準 PDF 產出／讀取方式，並以純合成文件驗證。來源文件未修改；不要求停用保護服務、外掛或驅動。若流程涉及核准工具身分，請依實際使用的成品確認；開發版與獨立發行版不是同一執行檔。

## 本輪文件校正與保護

README 原將 IGEF 稱為「微軟 Office 暫存狀態」並概括等待 90 秒，與證據及實作不符。已改為非標準 PDF／保護格式偵測：預設整體等待上限為 90 秒，持續 IGEF 約 5 秒即拒絕，不會無條件等待滿 90 秒。

未停用或移除外掛、服務、驅動；未改 Registry、保護策略、PATH、Python、使用者文件或產品 C#。本輪僅更新 README、中央診斷報告、改善總表及交接。未 Commit／Push；憲法與 Skill 沒有異動，不需設定同步。

Office 可讀性列為**待管理端流程確認的環境限制**；其他已通過的代表性功能結果保留。

最終核對：5 個保護檔案雜湊一致；兩個 Repository 的 HEAD／分支／索引不變，本輪文件差異、語言及隔離腳本語法檢查通過，診斷產物已被 Git 忽略。DesktopFramesPlus PID 5764 仍為 2.9.4.0，Office 殘留 0，合成 RTF 雜湊與原定內容一致。一次唯讀 git rev-parse HEAD 停滯，已只回收本輪宿主及子程序；原因未確認，沒有將其歸因到文件保護。後續直接讀取 HEAD／ref 並完成 Git 狀態／索引與文件範圍檢查，證據見同一診斷目錄的 verification-final.json、git-after.json、protected-after.json 及 process-final.json。
