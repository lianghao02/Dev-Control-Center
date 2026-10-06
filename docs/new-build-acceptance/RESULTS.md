# 新成品套用與代表性功能驗收

日期：2026-10-06。依使用者授權套用本機新成品、保留現有功能與資料；不是正式 Release，也不代表所有功能或跨電腦驗收完成。

後續 IGEF 診斷已找到正在執行的 GoPatrol 保護服務／驅動，依辦公室文件加密環境限制追蹤；精確規則及可讀 Office PDF 仍待管理端流程確認。見 [診斷報告](IGEF-DIAGNOSIS.md)。下列原始驗收結果與當時的待確認事實保留，不改寫成 Office 全部通過。

## 本輪結論

| 專案 | 實際結果 | 判定與邊界 |
|---|---|---|
| DesktopFramesPlus | 本機 `dist/DesktopFramesPlus` 更新為 2.9.4.0，13 項隔離斷言通過；新版已啟動並保持執行。 | 本機成品套用與代表性功能通過；ZIP 及 Code 下舊 Release 未更新。 |
| 10 照片整理 | 使用正式 WinShellReader 分析資料夾／Takeout ZIP；各 6 組媒體、1 組完全重複、1 組截圖，歸檔預覽各 6 組，沒有錯誤。 | 合成分析／預覽通過，來源雜湊不變；未執行原始照片實體整理。 |
| 12 ClipMask | 遮罩細紋降低、SRT 讀回、遮罩字幕壓制、快速剪輯及音量活動區間通過；成品可解碼且有音軌。 | 合成影音功能通過；未驗證真人臉追蹤與完整滑鼠操作。 |
| 15 ChainFlow | 隔離歷史保存／還原一致；CSV、TXT、SVG、調證 CSV、證據 ZIP、Agent ZIP 均成功，ZIP 完整性通過。 | 離線匯出通過；測試阻擋 socket.connect，未做線上採集，未讀寫正式案件歷史。 |
| 09 PaperSwitch | Word／Excel／PowerPoint 正式 COM 均返回輸出，但三份檔頭為 IGEF，標準可讀 Office PDF 為 0。既有拒絕防護與獨立標準 PDF 合併／旋轉／分頁通過。 | **Office 正常轉 PDF 未通過，環境阻斷仍存在。**來源雜湊不變，Office 殘留程序為 0。 |

## DesktopFramesPlus 更新與資料保護

更新前確認版本與清單並執行預覽。較完整的程序檢查確認舊版仍在執行，因此防護停止更新；使用者從常駐圖示正常結束後才套用。沒有強制結束使用者程序。

`scripts/apply_desktopframes_build.ps1` 預設只預覽；`-Apply` 才備份與套用。來源只允許程式、依賴、PDB 與語系檔案；核對缺件／版本，備份完整現行目錄，逐檔驗證 SHA-256。失敗時只回復本次套用的程式檔，不覆寫 Profiles。這次正常更新，未刻意注入磁碟故障驗證回復分支。

實際替換 22 個檔案，128 個其他檔案於更新前後 SHA-256 一致，包含 Profiles、Shortcuts、日誌與既有資料檔。完整回復副本保留在 Git 忽略的：

`artifacts/new-build-acceptance-20261006/update-2cc850bd261e403bbe3e068f461cfd25/before/`

`before.json` 與 `plan.json` 保存舊檔雜湊及更新範圍。需要回復時先從常駐圖示正常結束，再依 plan 只複製對應舊程式檔；不要把備份的 Profiles 整份覆蓋目前正在使用的配置。

更新後啟動同一 dist 路徑的 EXE，版號為 2.9.4.0；PID 5764、22 個原生視窗中 3 個可見，沒有 crash.log。活動日誌確認既有便箋與面板資料載入。**啟動前後 124 個 Profiles 檔案雜湊一致**；日誌隨正常使用更新，不回復覆寫活動記錄。新版保持執行供使用者使用。

日常入口為 `DesktopFramesPlus/dist/DesktopFramesPlus/Desktop Frames.exe`；`Run-Latest.bat` 是開發入口，Code 的 Profiles 與 dist 個人配置不同，不能當作個人配置更新入口。

## 代表性驗證內容與重跑

DesktopFramesPlus 新增 `tools/acceptance-tests` 與 `tools/test-representative-functions.ps1`。只接受具標記的新隔離目錄，透過真正 DLL 驗證版本、繁中設定、Data 面板尺寸及動態屬性、文件／資料夾捷徑參照、面板保存讀回、原生視窗、便箋顯示／隱藏、文字樣式保存、損毀便箋備份及防空清單覆寫，最後核對合成來源雜湊，共 13 個斷言通過。

測試 EXE 與產品入口不同，宿主在建立視窗前指定產品 WPF 資源來源，並透過公開 API 初始化面板選項；只影響測試程序，不修改產品 DLL。中途宿主資源定位、選項前置與 Windows PowerShell 退出碼取得問題已修正；歷次失敗記錄保留。最終測試正常退出 0，另有真正產品啟動證據；沒有將宿主修正當成產品 Bug。

```powershell
# 於 DesktopFramesPlus 根目錄；不寫入日常 Profiles
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test-representative-functions.ps1 -BinaryDir dist/DesktopFramesPlus
```

中央合成生成器已改用正式 WinShellReader，移除舊驗收替代器、修正未來素材包的舊說明。10／12／15 各自使用既有 .venv；資料與結果保存於：

`artifacts/test-runs/synthetic-acceptance/20261006-084650-6218bd75/`

```powershell
# 於工作區；產生全新素材包，不覆寫前次資料
& .\12_ClipMask-AI\.venv\Scripts\python.exe -X utf8 -B -s .\00_Dev-Control-Center\scripts\tests\create_synthetic_acceptance_pack.py
```

影音來源 90 影格，壓制成品 89 影格／6 秒，快速剪輯 45 影格／約 3.133 秒；不是逐影格無損或任意切點精準匯出的驗收。音調與細紋方塊只是聲學／遮罩素材，不代表真人辨識品質。

## PaperSwitch：已確認事實與尚待確認

本機 Word、Excel、PowerPoint COM 註冊存在，開始前沒有使用者 Office 程序。只建立合成 RTF／CSV／PPTX，使用現有 Release DLL 的正式 STA COM 服務匯出；沒有啟動 PaperSwitch 主視窗或讀寫其正式 converted／temp_converted 資料。

**已確認**：三種 Office 輸出均為 `IGEF` 檔頭；既有 `WaitForPdfReadyAsync` 拒絕將它們視為標準 PDF。標準可讀 Office PDF 為 0、阻斷為 3；不是完整 Office 轉檔通過。程式原有 ViewModel 會在此分支標示失敗並提示依規定處理，這部分為原始碼檢查；本輪沒有逐項點選介面確認提示。

**推測**：輸出可能受到本機加密／保護流程影響；尚未確認是哪個元件或規則，不能只靠 IGEF 檔頭斷言廠商或根因。**尚待驗證**：以管理端允許且可產出標準 PDF 的方式重新驗收三種 Office 轉檔，不更動或繞過端點保護。

新增中央 `scripts/tests/office_acceptance` 與 `test_office_acceptance.ps1`。測試另外建立三份標準空白 A4 PDF，正式合併為三頁、旋轉第二頁 90 度及逐頁匯出通過；這些標準合成 PDF 與 IGEF Office 輸出分開處理，沒有解密、改檔頭或重新命名以繞過限制。驗收工具成功退出只代表防護與可測功能檢查完成；`BlockedOfficePdfs > 0` 明確表示正常 Office 轉檔仍未通過。

```powershell
# 於控制中心；指定現有 PaperSwitch Release DLL 目錄
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/test_office_acceptance.ps1 -BinaryDir <PaperSwitch成品DLL目錄>
```

最終紀錄：`artifacts/new-build-acceptance-20261006/中文 Office 驗收-72a4a98e6250471aa13f4c1fbff4e998/verification.json`。最初未通過的 Office PDF 可讀性測試紀錄保留，不改寫成通過。

## 修改與未處理範圍

新增受控本機套用工具與代表性測試，最小更新中央忽略規則、合成生成器、相關 README／HANDOFF／改善總表。未修改桌面核心 C#、照片分類、影音匯出或金流演算法；未改全域 Python、PATH、VS Code 直譯器或重建 .venv，未執行 pip 安裝／移除。

沒有 Commit／Push、建立 Release 或覆寫原有 ZIP；既有未提交成果與 10 的 1,011 項 runtime 索引移除繼承。全域大型套件去重、01／07 等舊發布包重建、Windows 10／其他使用者／乾淨電腦、真人素材、完整原生互動與線上採集仍另行驗證。這輪不重跑未修改的全部專案測試，也不宣稱五個專案全部功能都已通過。

最後檢核：六個 Repository 的 `git diff --check` 通過，HEAD、分支與索引保持基準；10 的 1,011 項既有索引移除不變。新版 dist 再跑 13 項隔離斷言通過；新增 PowerShell 腳本語法、Python AST、產物忽略與工具敏感字串檢查通過。最終 DesktopFramesPlus 程序仍在執行，Office 與驗收宿主程序均為 0。證據在 `artifacts/new-build-acceptance-20261006/git-final.json`、`process-final.json`；未改憲法／Skill／Agent 部署設定，因此沒有進行設定同步。
