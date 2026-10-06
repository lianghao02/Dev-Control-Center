# 既有未修正問題處理結果

日期：2026-10-06。任務：FIX。依改善總表與目前交接處理已確認問題，承接 PaperSwitch 已完成修復；不擴大重構正常模組。

## 照片整理：Shell 無限等待與程序生命週期

修復前在無回應的合成子程序中，入口無法於期限內返回，直到子程序結束才解除；正式實作的 stdin 初始化／寫入及 stdout.readline 均沒有期限，stderr 管道也未消耗。重複 start 會另開程序而未先回收前一個程序。

修正 `main.py` 的 WinShellReader：

- 用編碼啟動腳本與 STA 執行 PowerShell；初始化不再塞進 stdin。
- 讀寫由背景執行緒處理，單次回應等待預設 15 秒；同一時間只有一個請求，避免錯配回應。
- 不保留無人讀取的 stderr 管道；helper 的 COM 失敗仍回傳既有 JSON 失敗結果。
- start 冪等；逾時、斷線或回應格式錯誤會關閉並等待自己建立的程序，回收管道；丟棄舊通道，下一次請求重新啟動。
- 維持 get_properties、create_shortcut、resolve_shortcut 的原有介面與失敗回傳，沒有更改日期／分類演算法、SQLite 格式或來源媒體操作。

**驗證**：完整 unittest 執行 148 項，147 通過、1 略過、0 失敗。新增 8 項含無回應、超大寫入阻塞、stderr 塞滿、冪等啟動、並行請求、中文空白捷徑、正常重啟及正式 Shell 的資料夾／ZIP 各兩次分析。來源照片、sidecar、ZIP 雜湊不變，沒有使用替代讀取器。

一次中途重跑遇到 15 秒逾時，已能回收並返回失敗，後續單獨複測成功；明確指定 STA 後的完整回歸通過。本次證實無限等待已受控，不能宣稱 Windows 或第三方 Shell 元件永遠不會忙碌／失敗；前輪 180 秒現場已清除，精確 COM 根因無法還原。正式 GUI 全程人工操作另行驗收。

## DesktopFramesPlus：版本識別、入口與打包

確認 csproj 與既有 DLL 均為 2.8.1，而維護交接為 2.9.4；打包名稱預設另寫死 2.9.0。入口將 bin／obj 生成來源納入時間判斷，依 apphost 時間判斷新舊，且未檢查建置失敗。

修正：

- csproj 的 Version 改為 2.9.4，AssemblyVersion／FileVersion 為 2.9.4.0；XML 編碼宣告符合實際 UTF-8 檔案。
- 打包名稱由專案版本取得，檢查標籤及實際 DLL 版本；不符時在寫入 ZIP／dist 之前停止。新增 CheckOnly 與獨立 BinaryDir 檢查。
- 入口排除 bin／obj、以 DLL 判斷來源新舊，動態探索 MSBuild；建置失敗不啟動舊版。執行中若需要建置，先提示正常結束，不強制關閉或覆寫個人配置。
- PowerShell 中文腳本保留 UTF-8 BOM，支援 Windows PowerShell 5.1 與 PowerShell 7。

**驗證**：以既有 Visual Studio MSBuild 在控制中心忽略的獨立目錄建置成功，Assembly／FileVersion 均為 2.9.4.0；圖示轉移回歸通過，674 個英文基準資源鍵全部有繁中對應。兩種 PowerShell 入口／版本防護各 7 項通過，涵蓋缺成品、有效 DLL、生成檔更新、錯標籤、錯組件版號及真正來源更新；假 EXE 不執行、不建立 ZIP，測試 Profiles 雜湊一致。

使用者正在執行 dist 中的舊程式，因此本輪沒有替換該目錄、終止程序或重新發布 ZIP。保護清冊 150 檔中，149 個檔案雜湊一致，包含既有成品與 Profiles；唯一變更為執行中程式的 Desktop_Frames.log 活動日誌，未將它還原覆寫。若要啟用來源校準後的版本，先正常結束程式，再以 [Run-Latest.bat](../../../DesktopFramesPlus/Run-Latest.bat) 建置／啟動。正式更新或發布另依發布門檻。

## Git、治理與保護

依全域憲法、lianghao-development FIX 與 windows-tool-ux 流程先重現、最小修改、真實驗證。未改中央憲法或 Skill，不需要部署同步；未安裝／移除全域套件、修改 PATH 或重建虛擬環境。

本 Agent 沒有 Commit／Push。10 與控制中心 HEAD 保持；DesktopFramesPlus 期間出現外部提交 `fb5c48a`，只含 README／HANDOFF，已核對並保留，沒有將本輪修復提交。原有 10 的 1,011 項 runtime 索引移除保持；本機 runtime 不刪除。

既有 nullable、未使用欄位警告沒有擴大修正；全域套件去重、正式發布、乾淨電腦／Windows 10 驗收與 12 的影格／端點觀察不屬已確認且可由本輪直接修正的產品 Bug，維持原有驗證邊界。

本機完整測試紀錄、建置輸出、保護清冊位於 Git 忽略的 `artifacts/remaining-fixes-20261006/`；不提交個人設定或資料路徑清冊。各專案 README／HANDOFF 與中央改善總表已更新。

最後檢核：三個 Repository 的差異格式與既有索引核對通過，沒有新增暫存；10 的 1,011 項既有索引移除維持。語法樹比對確認照片程式除 WinShellReader 與 queue 匯入外不變；相關文件連結存在。最終保護清冊排除唯一活動日誌後一致。
