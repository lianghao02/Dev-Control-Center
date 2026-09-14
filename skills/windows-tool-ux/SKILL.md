---
name: windows-tool-ux
description: Windows 桌面與公務工具產品設計與 UX 體驗技能庫。專注於 Windows 10/11 雙相容、免安裝 Portable 架構、零假死快速啟動、高 DPI 縮放適配、耗時任務進度可取消性與公務無管理者權限環境相容。
---

# 🖥️ Windows Tool UX Skill (v1.0.0)

本技能提供 LiangHao 開發生態系之 Windows 桌面應用程式（WPF、Python GUI、Tauri、PowerShell GUI、Portable Exe）在真實辦公環境下的產品架構限制、啟動效能與 UX 互動設計原則。

## 1. 核心產品與體驗準則

1. **真實公務與 Windows 環境相容性 (Public Office Compatibility)**：
   - 基準涵蓋：**Windows 10 與 Windows 11**。
   - 容錯防線：支援中文使用者名稱、含空白與中文字元之路徑；無 Microsoft Store、無本機系統管理員 (Admin) 權限、無預裝 Office 環境。
2. **免安裝可攜性標準 (Portable Design)**：
   - 執行檔零相依：免安裝單檔或免安裝目錄，不依賴原開發機絕對路徑，不強制要求全域安裝 Python 或 .NET SDK。
   - 資料隔離：應用程式二進位檔 (Binaries) 與使用者產出資料/設定嚴格分離，更新 App 絕不覆蓋使用者既有設定。
3. **啟動效能與零假死原則 (Startup Performance)**：
   - **防範啟動假死**：避免在主執行緒執行重量級 Blocking 作業（如無超時之網路請求、全硬碟掃描或重型模型載入），若冷啟動會造成使用者可感知之凍結或無回應風險，應考慮非同步、延遲載入或快取優先；單純小工具不強制過度架構化。
4. **耗時任務透明度 (Long-Running Tasks)**：
   - 若操作會造成可感知等待或 UI 無回應風險，應視任務性質提供非同步背景處理、進度指示（數值百分比或 indeterminate 動畫）、取消中斷機制與錯誤提示。具體門檻依專案實測與使用者體感決定，不以固定秒數作為所有專案之強制規則。
5. **桌面 UI/UX 核心語意**：
   - 一眼理解目前狀態與下一步；避免「看起來像當機」。
   - 高 DPI（125%、150% 縮放）自適應：嚴禁使用固定像素 (Absolute Pixel) 硬排版，防止在高解析度螢幕發生文字被切斷。

## 2. 目錄結構與資源指引

- **規範文件（`references/`）**：
  - `windows-compatibility.md`：Windows 10/11 邊界、中文路徑與非管理者權限。
  - `portable-design.md`：免安裝工具目錄隔離與資料保存邊界。
  - `startup-performance.md`：冷啟動優化、非同步管線與防假死策略。
  - `desktop-ux.md`：狀態透明、DPI 縮放與版面人體工學。
  - `long-running-tasks.md`：背景執行緒、進度回報、取消中斷與重試。
  - `public-office-environment.md`：公務離線電腦硬體受限與網路隔離情境。
- **標準流程（`workflows/`）**：
  - `review-desktop-ux.md`：桌面工具 UI/UX 審核與操作流暢度診斷。
  - `review-startup.md`：冷啟動瓶頸定位與假死消除流程。
  - `review-portable-release.md`：Portable 免安裝發行包相容性審驗。
- **檢核清單（`checklists/`）**：
  - `windows-compatibility.md`：Windows 10、非 Admin、中文路徑合規檢核。
  - `desktop-ux.md`：狀態可見度、高 DPI 縮放與錯誤提示檢核。
  - `portable-release.md`：免安裝打包潔淨度與相依性驗收檢核。
- **範例庫（`examples/`）**：
  - `good-startup.md`：非同步背景初始化與即時可互動代碼範例。
  - `blocking-ui.md`：常見主執行緒阻塞錯誤與修正對比。
