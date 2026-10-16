---
name: accesslint
description: >
  自動化無障礙 (a11y) 掃描與檢測工具。針對 WCAG 2.1 / 2.2 標準驗證 HTML 頁面。
  適用於對外網站、正式公務系統、有明確 WCAG 無障礙要求或使用者指定檢測的場景。
---

# AccessLint — 無障礙規範自動化掃描

## 適用情境與觸發邊界

- **適用場景**：對外公開網站、正式公務/警政系統、具備無障礙合規要求之專案，或使用者明確要求進行無障礙檢查時。
- **一般內部工具**：內部使用或小型工具頁面僅套用基本的語意 HTML 與可讀性原則，不強制執行完整 WCAG 掃描流程。

---

## WCAG 主要檢查項目

| 分類 | 具體檢查項目 |
|:---|:---|
| **對比度** | 文字與背景色彩對比度 ≥ 4.5:1（正文）/ 3:1（大文字） |
| **語意 HTML** | 標題層級（`<h1>` → `<h6>`）層級正確、使用語意標籤 |
| **表單標籤** | 每個 `<input>` 具備對應 `<label>` 或 `aria-label` |
| **圖片替代文字** | `<img>` 具備適當 `alt` 屬性 |
| **鍵盤可及性** | 互動元素可用 Tab 鍵操作與觸發 |
| **焦點視覺** | 焦點指示器清晰可見（`:focus` 樣式） |
| **ARIA 使用** | `aria-*` 屬性正確使用，無語意衝突 |

---

## 掃描工具與離線防禦原則（對齊 `webapp-testing` 與 `data-safety`）

- **工具優先序**：優先使用內建 Browser 工具或專案既有的 Node.js Playwright 測試環境；**不得為單次無障礙掃描臨時執行 `pip install playwright` 或改動專案相依套件**（僅在專案本身已具備受管之 Python Playwright 環境時才使用 Python 腳本）。
- **離線與隱私防線**：涉及公務、警政、個資或離線環境之專案，一律使用本機離線 `axe.min.js` 注入，嚴禁未經授權載入外部 CDN。

### 掃描實作範例（本機離線 `axe.min.js` 優先）

```javascript
// Node.js Playwright 既有環境範例（優先載入本機 axe.min.js）
await page.goto(url, { waitUntil: 'domcontentloaded' });
await page.addScriptTag({ path: localAxePath }); // 公務/離線專案強制使用本機路徑
const results = await page.evaluate(async () => {
  const res = await window.axe.run();
  return {
    violations: res.violations.map(v => ({
      id: v.id,
      impact: v.impact,
      description: v.description,
      helpUrl: v.helpUrl,
      nodes: v.nodes.length
    })),
    passes: res.passes.length
  };
});
```

---

## 報告輸出格式

```text
🔍 無障礙掃描報告
==================
❌ 嚴重 (critical): color-contrast — 3 個元素對比度不足
❌ 重大 (serious): label — 2 個表單欄位缺少標籤
⚠️ 中等 (moderate): heading-order — 標題層級跳躍

✅ 通過檢查：47 項規則
```
