---
name: taiwan-office-automation
description: 臺灣公務與辦公文件資料自動化共用技能庫。涵蓋民國日期時間正規化、Excel 帳號與長數字完整性保護、Word/PDF 套版生成、臺灣正式公文語氣與公務流程規範。
---

# 🏛️ Taiwan Office Automation Skill (v1.0.0)

本技能提供臺灣公務與行政辦公自動化之專門領域知識、資料保護策略與文件排版規範。

## 1. 核心知識領域

1. **民國日期時間規範 (ROC Date & Time)**：精準辨識解析民國紀年（如 `114/09/05`、`1140905`）與時間戳（`130700` ➜ `13:07:00`），區隔顯示與底層儲存。
2. **Excel 資料語意完整性 (Excel Data Preservation)**：保護銀行帳號、身分識別碼、電話、長數字與前導零，嚴禁被 Excel 轉為科學記號（`1.23E+15`）。
3. **金額與識別碼分離原則**：金額可進行整數化與千分位格式化；帳號、電話、ATM 代碼等識別碼一律作為純文字處理。
4. **Word / Office 套版與 COM 安全**：樣板套印、動態表格、圖片縮放排版；不依賴固定印表機或使用者本機 `Normal.dotm`。
5. **PDF 資料處理與雙軌辨識**：區分「文字型 PDF」與「掃描型 PDF」，原則上不覆寫原始 PDF。
6. **臺灣正式文書語氣 (Formal Writing)**：符合臺灣公務正式結構與繁體中文用語；缺漏資訊明確以 `[待補]` 標註，嚴禁捏造人名、案號或案情。

## 2. 目錄結構與資源指引

- **規範文件（`references/`）**：
  - `roc-date-time.md`：民國年、西元年、時間格式轉換原則與邊界。
  - `excel-data-preservation.md`：防範長數字科學記號與前導零消失之保存機制。
  - `word-office-automation.md`：Word 套版、COM 生命週期與環境相容性。
  - `pdf-document-processing.md`：PDF 擷取、重組與雙軌文字處理。
  - `taiwan-formal-writing.md`：臺灣公文與正式函文之語意風格與事實約束。
  - `public-sector-workflows.md`：警政、行政機關工作資料處理常見情境。
- **標準流程（`workflows/`）**：
  - `normalize-tabular-data.md`：表格欄位類型偵測、清洗與防轉型流程。
  - `generate-office-document.md`：Word / Excel 報表自動生成與套版驗收。
  - `transform-pdf-data.md`：PDF 轉結構化資料作業流程。
  - `review-formal-document.md`：正式文案與公文用字審核流程。
- **檢核清單（`checklists/`）**：
  - `excel-integrity.md`：長數字、帳號、日期欄位防呆檢驗清單。
  - `office-output.md`：跨版本 Office 輸出與排版驗收清單。
  - `formal-document-review.md`：公務正式用語與未確定事實標記檢核。
- **範例庫（`examples/`）**：
  - `roc-datetime.md`：日期時間常見髒資料與轉換對照範例。
  - `long-number-preservation.md`：帳號、身分證號、電話防失真處理範例。
  - `formal-writing.md`：公務正式通報與簽呈結構範例文案。
