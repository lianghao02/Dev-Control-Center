---
name: accesslint
description: >
  無障礙 (a11y) 檢測流程與離線 axe 執行範例；需既有瀏覽器及本機引擎，非內附掃描工具。依 WCAG 2.1 / 2.2 檢查 HTML 頁面並記錄人工驗證限制。
  適用於對外網站、正式公務系統、有明確 WCAG 無障礙要求或使用者指定檢測的場景。
---

# AccessLint — 無障礙規範自動化掃描

## 適用情境與工具分流

- **適用場景**：對外公開網站、正式公務／警政系統、具備 WCAG 2.1/2.2 合規要求之專案，或使用者明確要求執行無障礙掃描。
- **一般內部工具**：僅套用基本語意 HTML 與可讀性原則，不強制完整 WCAG 掃描。
- **與 `a11y-debugging`（Chrome DevTools MCP）分工**：
  - 本 Skill 專注**無網路／公務／離線合規場景**，優先使用本機離線 `axe.min.js` 自動化規則掃描，嚴禁未經授權載入外部 CDN。
  - 若於線上開發環境進行即時鍵盤焦點、ARIA 樹與對比度互動除錯，可搭配已安裝的 `chrome-devtools-plugin`（`a11y-debugging`）。

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

## 掃描工具與離線防禦原則（對齊 `webapp-testing` 與 `lianghao-development/references/data-safety.md`）

- **工具可用性**：本 Skill 提供執行規範與範例，未內附 axe 或瀏覽器引擎。先確認本機 axe 路徑、版本與授權來源；缺少工具時記為「自動掃描略過」，仍可記錄實際完成的人工檢查，不臨時下載或假稱通過。
- **工具優先序**：優先使用 Agent 內建瀏覽器／Playwright MCP 或專案既有 Node.js Playwright 測試環境；**不得為單次無障礙掃描臨時執行 `pip install playwright` 或改動專案相依套件**。
- **離線與隱私防線**：涉及公務、警政、個資或離線環境之專案，一律注入本機離線 `axe.min.js`，嚴禁未經授權載入外部 CDN。

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
      nodes: v.nodes.map(n => ({
        target: n.target,
        failureSummary: n.failureSummary
      }))
    })),
    incomplete: res.incomplete.map(v => ({
      id: v.id,
      nodes: v.nodes.map(n => ({ target: n.target, failureSummary: n.failureSummary }))
    })),
    passes: res.passes.length
  };
});
```

---

## 掃描結果的限制與追蹤

- 記錄 axe 版本、規則集、頁面／狀態、瀏覽器與尺寸；保留違規節點的 selector、failureSummary 及需人工判斷的 incomplete 項目，避免只留數量而無法定位。
- 另實際檢查鍵盤順序、焦點可見度、彈窗焦點返回及錯誤復原；未測的輔助科技明列待驗證。零 violations 只代表本次已執行規則未發現問題，不等於 WCAG 全面合規。
- axe impact 保留為工具原始等級；交付優先順序依 [UI 審查流程](../product-design/references/ui-review.md) 的任務影響分類判斷，不將 moderate 一律視為可忽略。修改後以相同狀態重掃並核對新增、解決及保留項目。

## 報告輸出格式

以下僅為格式示例，不是實測結果：

```text
🔍 無障礙掃描報告
==================
❌ 嚴重 (critical): color-contrast — 3 個元素對比度不足
❌ 重大 (serious): label — 2 個表單欄位缺少標籤
⚠️ 中等 (moderate): heading-order — 標題層級跳躍

✅ 通過檢查：47 項規則
```
