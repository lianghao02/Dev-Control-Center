# Word 與 Office 自動化規範 (Word & Office Automation)

## 1. 樣板與排版原則
- **樣板分離**：公務報表與公文應建立標準範本檔（`.dotx`, `.docx`），程式僅負責填入標籤或書籤（Bookmarks / Content Controls），避免以程式碼從空白文件硬畫複雜表格。
- **動態表格**：多筆資料動態產生列時，應保留標題列重複（Repeat as header row at the top of each page）與跨頁不切斷列內容之設定。
- **圖片與鑑識附件**：公務佐證照片套入 Word 時，需固定比例縮放，避免拉伸變形；每張照片下方預留標準圖說欄位。

## 2. Office COM 生命週期與環境強健性
- **COM 物件釋放**：在 C# 或 Python 呼叫 Word/Excel COM 時，必須在 `finally` 區塊明確釋放 COM 物件（`Marshal.ReleaseComObject`），避免背景殘留無頭 `WINWORD.EXE` 行程。
- **環境自我檢測**：若執行環境未安裝 Microsoft Office，程式應友善提示缺失，或優先採用免安裝 Office 的開源處理庫（如 OpenXML, python-docx）產生文件。
- **零環境依賴**：
  - 不得依賴特定使用者設定目錄下的 `Normal.dotm`。
  - 不得依賴特定實體印表機驅動程式進行版面換算。
