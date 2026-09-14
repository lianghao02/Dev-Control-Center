# PDF 文件處理與雙軌辨識 (PDF Document Processing)

## 1. 文字型與掃描型 PDF 區分
- **文字型 PDF (Searchable / Vector PDF)**：
  - 含有字元編碼與文字串流（如系統直接匯出的公文或金融對帳單）。
  - 優先使用文字層擷取（如 pdfplumber, pypdf, PdfPig），通常比 OCR 更快速且可靠；仍須驗證實際抽取品質（注意字型 encoding、ToUnicode map、閱讀順序或文字轉 path 等特殊狀況）。
- **掃描型 PDF (Scanned / Raster Image PDF)**：
  - 本質為包裝在 PDF 內的高解析圖片（如公文掃描影像、歷史卷宗）。
  - 需透過本機 OCR 引擎（如 Tesseract、Windows 內建 Media OCR）進行文字辨識。
  - 嚴禁未經確認就對所有文字型 PDF 盲目套用耗時且可能掉字的 OCR。

## 2. 原始檔案保護
- 任何旋轉、裁切、浮水印加註、去機密遮罩（Redaction）或合併分割，原則上均輸出至新檔案（如 `[原檔名]_processed.pdf`）。
- 嚴禁直接就地覆寫（In-place overwrite）原始送鑑或公務卷宗 PDF。
