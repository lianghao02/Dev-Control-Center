# 開發環境與工作區路徑架構備忘錄

> 本機 GitHub 開發專案的實體資料位於 `D:\Development\GitHub`；舊路徑 `C:\Users\<使用者名稱>\Documents\GitHub` 若以 NTFS Junction 保留，僅供既有工具與腳本相容使用。

## 1. 路徑動態解析原則

開啟開發專案時優先直接選擇 `D:\Development\GitHub`。程式碼不得寫死使用者目錄或磁碟機路徑，應依語言動態取得執行位置：

- Python：`Path(__file__).resolve().parent`
- PowerShell：`$PSScriptRoot`
- Batch：`%~dp0`
- VBA：`ThisWorkbook.Path`

## 2. Python 虛擬環境搬遷規範

`.venv` 可能包含建立當時的絕對路徑，不應將既有虛擬環境視為可直接搬移的成品。專案搬遷或更換環境後應依 `requirements.txt`、`pyproject.toml` 或鎖定檔重新建立：

1. 確認系統目標 Python（3.13）可正常執行。
2. 確認專案具備完整依賴清單。
3. 在乾淨位置建立新虛擬環境並以 `-m pip` 安裝依賴。
4. 驗證新環境可啟動且必要套件可匯入，才替換失效環境；不得使用忽略錯誤的批次刪除。

啟動腳本若偵測到 `.venv` 失效，應清楚提示並停止，或在取得使用者確認後重建，不得只修改 `pyvenv.cfg` 後假設環境已修復。

## 3. 現行管理專案目錄（共 17 個）

```text
D:\Development\GitHub\
├── 00_Dev-Control-Center/
├── 01_AG-MONITOR-Smart-Video-Screening/      # Python 3.13 (python_embed)
├── 02_Cell-Tower-Map-Locator/
├── 03_Police-Image-Toolkit/
├── 04_Photo-Report-Generator/
├── 07_auto-learning-bot/                     # Python 3.13 (python_embed)
├── 08_Financial-Data-Parser/
├── 09_PaperSwitch/
├── 11_Calendar-Card-App/
├── 12_ClipMask-AI/                           # Python 3.13 (.venv)
├── 13_Project-Hub/
├── 14_Google-Photos-Takeout-Organizer/       # Python 3.13 (.venv)
├── 16_Wuxia-Typing-Legend/
├── 17_Subscription-Manager/
├── 18_AromaCraft-Studio/
└── 19_DesktopFramesPlus/
```

（`05`、`06`、`10`、`15`、`20` 已封存或停用，不列入現行同步與環境建置範圍。）
