# PaperSwitch 本機入口修復結果

日期：2026-10-05。任務：FIX。範圍為 `09_PaperSwitch` 的本機啟動／建置入口，沒有 Commit、Push 或正式發布。

## 結果

已修復「入口要求重新建置」的既有待辦。`dist/publish/PaperSwitch.exe` 已重新產生，兩種 PowerShell 的入口檢查與實際 EXE 主視窗啟動通過。使用入口為 [RUN.bat](../../../09_PaperSwitch/RUN.bat)。

## 已確認原因與修正

| 問題 | 修正 |
|---|---|
| publish 原本只有 PDB、version.txt，缺少 EXE | 使用既有建置腳本實際產生 framework-dependent EXE，26.56 MiB。 |
| bin／obj 生成的 .cs 比現有成品新，誤判需要重建 | 來源時間檢查排除這兩類目錄；真正來源／資源更新仍要求建置。 |
| 過舊 publish 會阻斷後續有效候選；Release apphost 時間不一定等同實際組件時間 | 依 publish、win-x64 Release、未指定 RID 的 Release 順序逐一檢查；Release 以 DLL 時間判斷。建置後也使用同一檢查。 |
| Windows PowerShell 5.1 解析中文腳本失敗 | run.ps1、build.ps1 及新入口測試採 UTF-8 BOM；PowerShell 7 同樣驗證。 |
| build.ps1 建置前刪除整個 publish 資料夾 | 移除整目錄刪除，改由正常 publish 更新建置輸出。此舉不代表清理歷史成品或重新發布。 |
| README 宣稱 7 天自動清理，與目前原始碼不符 | 校正為使用者按「清除暫存」並確認後才清除 converted／temp_converted；啟動不會自動清除。 |

## 實際驗證

指令從 PaperSwitch Repository 根目錄執行；SDK 使用既有安裝，本輪未變更 PATH、全域設定或 NuGet 相依版本。

| 驗證 | 結果 |
|---|---|
| `powershell.exe -NoProfile -ExecutionPolicy Bypass -File dotnet-src/scripts/build.ps1` | 結束碼 0，發布 EXE 產生。 |
| `pwsh -NoProfile -File dotnet-src/scripts/test-launcher.ps1 -PowerShellHost pwsh.exe` | 8／8 通過。 |
| 相同入口測試指定 `-PowerShellHost powershell.exe` | 8／8 通過。 |
| 既有 SDK 執行 `dotnet test dotnet-src/PaperSwitch.sln -c Release --no-restore --nologo --verbosity minimal` | 50 通過、0 失敗、0 略過，包含 WPF STA XAML 載入測試。 |
| PowerShell 5.1／7 的 `run.ps1 -ValidateOnly` | 均指向本機 publish EXE，核心測試生成的 obj 不再觸發誤判。 |
| 重複入口檢查 | 兩種主機均再次通過，EXE 雜湊及修改時間完全不變。 |
| 隱藏啟動本輪發布 EXE，檢查主視窗 | 主視窗標題「PaperSwitch 紙張排版工坊 — 文件轉 PDF 與視覺化裝訂」，視窗控制代碼有效；結束時僅關閉本輪擁有的程序。 |
| GUI 前後使用者資料雜湊 | 46 個既有檔案一致。 |
| 保護清冊與既有修改 | 32 個來源／既有成品檔案不變；原有 AGENTS.md 修改完整保留。publish PDB 為本次建置產物，不納入不可變清冊。 |
| Git 與文件 | PaperSwitch／控制中心差異格式檢查通過；main／HEAD 不變，兩個 Repository 索引皆無暫存檔案；相關文件連結存在。 |

入口回歸涵蓋：無成品、缺 publish、生成檔案更新、過舊 publish 回退、新 publish 優先、真正來源更新、未指定 RID 的 Release、版本資源更新。測試位於中文與空白的獨立暫存路徑，只使用假成品執行 ValidateOnly，不啟動假 EXE、不建置、不觸碰正式資料。

第一次 GUI 驗證被自動核准審查拒絕，原因是懷疑啟動會清理既有資料。隨後檢查 App、MainWindow、MainViewModel 的啟動流程及清理事件呼叫，確認清理只由明確按鈕與確認對話框觸發；加入資料前後雜湊核對後，驗證獲准並通過。沒有為此修改產品行為。

## 保護範圍與限制

沒有修改 C#、XAML、專案檔、RUN.bat 或既有測試；沒有修改全域 Python、.NET 安裝、PATH、使用者設定。正式 `PaperSwitch-v4.3.0-Standalone.exe`、SHA256SUMS.txt、release_notes.md 雜湊維持原值。Git HEAD／分支不變，未暫存或提交本輪變更。

這次驗證涵蓋入口與本機主視窗，以及既有核心測試；未宣稱所有 Office COM 轉換、完整人工介面互動、Windows 10 或其他電腦已重新驗收。入口仍以檔案時間判斷新舊，不等同完整內容雜湊驗證。正式發布須另依發布門檻處理。

詳細本機基準與 GUI 雜湊證據保存於 Git 忽略的 `artifacts/paperswitch-launch-repair/`，不提交使用者資料路徑清冊。前輪目錄整理與 README 更新報告的失敗結果保留為當時事實，由本報告記錄後續修復。
