# 模擬執行與影響預覽標準 (Dry Run and Preview)

## 1. 適用範圍與適度性原則
- **批次與高風險作業**：涉及多檔案改名、分類、搬移或覆寫操作，或操作具備不可逆風險時，建議提供 Dry Run 模式、日誌或 UI 預覽清單；具體門檻依專案規模與實務風險決定。
- **避免過度框架化**：單一檔案處理或明確無害之輸出（如單純匯出一份新 Excel），**嚴禁強制引入複雜的 Dry Run 狀態機**，避免過度工程化。

## 2. Dry Run 預覽必備欄位
執行模擬時，系統輸出之報告或 UI 檢視表應清晰包含：
- **來源路徑 (Source)**
- **預計目標路徑 (Destination)**
- **預計執行動作 (Action)**：`Copy`, `Move`, `Skip`, `Rename`
- **衝突與重複標註 (Collision/Duplicate)**：如 `Collision: Target Exists (will append suffix)`
- **潛在風險警示 (Warning)**：如「檔名過長」、「特殊符號」、「缺少 EXIF 時間」
