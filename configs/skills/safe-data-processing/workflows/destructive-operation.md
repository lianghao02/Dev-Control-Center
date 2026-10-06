# 不可逆操作防護作業流程 (Destructive Operation Workflow)

1. **不可逆動作識別**：任何涉及刪除原始檔案、就地覆寫或不可逆壓縮之功能，必須標記為 `DESTRUCTIVE`。
2. **作業前前置檢查**：
   - 確認目標檔案已完整寫入。
   - 確認已執行至少一次 Dry Run 預覽，並有日誌紀錄。
3. **強制二次確認 (Explicit Confirmation)**：
   - GUI 介面跳出對話框，明確列出即將刪除之項目數量與總空間。
   - CLI 工具必須要求使用者輸入確認字元（如 `--yes` 或輸入 `DELETE`）。
4. **安全執行與回收支援**：
   - 優先調用 Windows Shell API 移至「資源回收筒」（Recycle Bin），而非永久刪除。
   - 記錄刪除檔案之完整絕對路徑日誌。
