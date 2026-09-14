# 桌面版面人體工學與高 DPI 適配 (Desktop UX & Scaling)

## 1. 高 DPI 與文字縮放自適應
- **常見縮放比例**：公務筆電與 4K 螢幕常見 125%、150%、175% Windows Display Scaling。
- **排版防破版鐵律**：
  - WPF 一律採用 `Grid` (Star sizing `*`) 與 `StackPanel`，嚴禁使用 `Canvas` 或固定數值之寬高（如 `Width="120"` 硬貼按鈕）。
  - HTML/Tauri 一律使用 `rem`、Flexbox 與 CSS Grid，文字容器允許折行（`word-break: break-word`）或溢位省略號（`text-overflow: ellipsis`）。
  - 防止文字因放大 1.25 倍而導致「按鈕文字只看得到一半」或「下排按鈕被推擠出視窗外」。

## 2. 狀態透明優先於美觀
- 介面隨時指示：
  1. 目前運作狀態（閒置、處理中、已完成、失敗）。
  2. 當前步驟與下一步指引。
  3. 錯誤原因與可行的補救動作。
