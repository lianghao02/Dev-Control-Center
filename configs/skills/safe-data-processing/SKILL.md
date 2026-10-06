---
name: safe-data-processing
description: 使用者原始資料安全處理標準技能庫。提供檢視優先 (Inspect)、模擬預覽 (Preview)、複製優先 (Copy)、衝突處理 (Collision)、重複偵測 (Duplicate) 與隔離區 (Quarantine) 機制，確保相片、音訊、影片、CSV/Excel 等使用者原始資產零損壞。
---

# 🛡️ Safe Data Processing Skill (v1.0.0)

本技能提供處理使用者原始資料（如 Google Photos Takeout、大量多媒體、批次改名、資料清理、歸檔搬移）之最高安全防護準則。

## 1. 核心處理原則

1. **核心作業流程**：
   ```text
   Inspect（檢視分析）➜ Preview / Dry Run（模擬預覽）➜ Copy（複製處理）➜ Verify（驗收比對）➜ Optional Move/Delete（選擇性清理）
   ```
2. **操作優先級防線**：
   ```text
   Copy（複製） > Move（搬移） > Delete（刪除）
   ```
3. **原始輸入保護原則 (Source Preservation)**：
   - 若本次模式宣告為 Read-only / Copy-only，來源數量與內容必須維持不變。
   - 若功能本身允許 Move/Rename/Delete，則依該次操作計畫與 Audit Log 驗證來源變化符合預期。
4. **同名衝突策略 (Collision Policy)**：
   - 嚴禁未經確認就地覆寫（Overwrite）。
   - 依專案策略明確選擇：跳過 (Skip)、自動序號後綴 (Version Suffix)、內容雜湊比對 (Compare Hash) 或移至隔離審查目錄。
5. **重複偵測嚴謹邊界 (Duplicate Detection)**：
   - 嚴格區分：檔名重複 (Filename Duplicate)、中繼資料重複 (Metadata Duplicate) 與內容雜湊重複 (Hash/Binary Duplicate)。不得僅因檔名相同即判定檔案內容相同。
6. **隔離與人工審查機制 (Quarantine & Review)**：
   - 建立隔離或人工審查機制（名稱可依專案命名，如 `Quarantine/`、`Review/`、`Duplicates/`、`_collisions/` 等），遇到無法可靠判定、格式毀損或疑義檔案，優先集中隔離記錄，優於直接拋棄。

## 2. 目錄結構與資源指引

- **規範文件（`references/`）**：
  - `source-data-protection.md`：原始資料夾唯讀防護與變更阻斷原則。
  - `copy-move-delete-policy.md`：複製、搬移與刪除之門檻與權限控管。
  - `collision-handling.md`：目標檔案同名碰撞之處置策略。
  - `duplicate-detection.md`：雜湊、大小與中繼資料多維重複判定模型。
  - `dry-run-preview.md`：大量批次作業之模擬執行與影響預覽標準。
  - `rollback-quarantine.md`：異常隔離與安全復原設計。
- **標準流程（`workflows/`）**：
  - `inspect-first.md`：作業前來源掃描、格式盤點與容量預估流程。
  - `safe-batch-process.md`：標準批次處理作業（含統計與摘要報告）。
  - `safe-organize.md`：檔案分類、歸檔與結構重組流程。
  - `destructive-operation.md`：不可逆操作（刪除/搬移）之強制確認防線流程。
- **檢核清單（`checklists/`）**：
  - `pre-operation.md`：批次處理啟動前之磁碟、來源與預覽檢核清單。
  - `post-operation.md`：作業完成後之筆數、雜湊與零遺失驗收清單。
  - `source-integrity.md`：原始輸入目錄未受污染完整性檢驗清單。
- **範例庫（`examples/`）**：
  - `copy-first.md`：複製優先架構代碼範例。
  - `collision.md`：序號後綴與防覆寫衝突處理範例。
  - `quarantine.md`：未知與疑義檔案自動隔離作業範例。
