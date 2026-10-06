# 目錄整理執行預覽

只執行下列明確項目；保留現行成品、環境、模型與其他案件資料。

| 動作 | 來源 | 目標／原因 | 檔案 | MiB |
|---|---|---|---:|---:|
| move | 00_Dev-Control-Center/config/agent-environment.example.json | 00_Dev-Control-Center/configs/agent-environment.example.json | 1 | 0.00 |
| move | 06_System-Optimizer-Tool/dotnet-src/publish | 06_System-Optimizer-Tool/dist | 11 | 138.41 |
| move | 12_ClipMask-AI/ACCEPTANCE_RECORD.md | 12_ClipMask-AI/docs/ACCEPTANCE_RECORD.md | 1 | 0.00 |
| move | 14_Google-Photos-Takeout-Organizer/匯出資料夾邏輯.txt | 14_Google-Photos-Takeout-Organizer/docs/匯出資料夾邏輯.txt | 1 | 0.00 |
| remove | 00_Dev-Control-Center/dist/synthetic-acceptance | 前輪合成測試產物，生成器保留 | 186 | 2.89 |
| remove | 04_Photo-Report-Generator/test_photos | 舊合成照片，現行 E2E 及 baseline 使用 tests/fixtures | 4 | 0.04 |
| remove | 12_ClipMask-AI/build | PyInstaller 中間產物及已結束的測試截圖 | 23 | 24.60 |
| remove | 09_PaperSwitch/dist/PaperSwitch-v4.1.2-Standalone.exe | 舊發行，現行 v4.3.0 保留 | 1 | 75.41 |
| remove | 09_PaperSwitch/dist/PaperSwitch-v4.2.0-Standalone.exe | 舊發行，現行 v4.3.0 保留 | 1 | 75.42 |
| remove | 09_PaperSwitch/dist/PaperSwitch-v4.2.1-Standalone.exe | 舊發行，現行 v4.3.0 保留 | 1 | 75.42 |
| remove | 09_PaperSwitch/dist/release_assets/PaperSwitch-v4.0.0-Standalone.exe | 舊發行，現行 v4.3.0 保留 | 1 | 75.31 |
| remove | 09_PaperSwitch/dist/release_assets/PaperSwitch-v4.1.0-Standalone.exe | 舊發行，現行 v4.3.0 保留 | 1 | 75.41 |
| remove | 09_PaperSwitch/dist/release_assets/PaperSwitch-v4.1.0-FrameworkDependent.zip | 舊發行壓縮包 | 1 | 7.46 |
| remove | 09_PaperSwitch/dist/SHA256SUMS.txt | 僅指向已移除的 v4.2.1；現行 release_assets 清冊保留 | 1 | 0.00 |
| remove | DesktopFramesPlus/dist/DesktopFramesPlus-v2.8.1-zh-TW.zip | 舊發行，現行程式及設定保留 | 1 | 12.70 |
| remove | DesktopFramesPlus/dist/DesktopFramesPlus-v2.9.0-zh-TW.zip | 舊發行，現行程式及設定保留 | 1 | 12.73 |
| remove | 01_AG-MONITOR-Smart-Video-Screening/__pycache__ | 可重建測試／編譯快取 | 1 | 0.11 |
| remove | 01_AG-MONITOR-Smart-Video-Screening/tests/__pycache__ | 可重建測試／編譯快取 | 2 | 0.02 |
| remove | 05_tw-formal-writing/scripts/__pycache__ | 可重建測試／編譯快取 | 2 | 0.02 |
| remove | 06_System-Optimizer-Tool/dotnet-src/src/SystemOptimizer.App/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 8 | 0.44 |
| remove | 06_System-Optimizer-Tool/dotnet-src/src/SystemOptimizer.App/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 68 | 0.61 |
| remove | 06_System-Optimizer-Tool/dotnet-src/src/SystemOptimizer.Core/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 3 | 0.08 |
| remove | 06_System-Optimizer-Tool/dotnet-src/src/SystemOptimizer.Core/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 13 | 0.13 |
| remove | 06_System-Optimizer-Tool/dotnet-src/tests/SystemOptimizer.Tests/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 90 | 4.47 |
| remove | 06_System-Optimizer-Tool/dotnet-src/tests/SystemOptimizer.Tests/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 16 | 0.14 |
| remove | 07_auto-learning-bot/.pytest_cache | 可重建測試／編譯快取 | 4 | 0.01 |
| remove | 07_auto-learning-bot/__pycache__ | 可重建測試／編譯快取 | 5 | 0.55 |
| remove | 07_auto-learning-bot/models/__pycache__ | 可重建測試／編譯快取 | 2 | 0.00 |
| remove | 07_auto-learning-bot/scripts/__pycache__ | 可重建測試／編譯快取 | 1 | 0.02 |
| remove | 07_auto-learning-bot/tests/__pycache__ | 可重建測試／編譯快取 | 26 | 0.15 |
| remove | 07_auto-learning-bot/utils/__pycache__ | 可重建測試／編譯快取 | 8 | 0.08 |
| remove | 09_PaperSwitch/dotnet-src/src/PaperSwitch/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 0 | 0.00 |
| remove | 09_PaperSwitch/dotnet-src/src/PaperSwitch/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 59 | 0.29 |
| remove | 09_PaperSwitch/dotnet-src/tests/PaperSwitch.Tests/TestResults | 可重建測試／編譯快取 | 1 | 125.71 |
| remove | 09_PaperSwitch/dotnet-src/tests/PaperSwitch.Tests/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 0 | 0.00 |
| remove | 09_PaperSwitch/dotnet-src/tests/PaperSwitch.Tests/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 4 | 0.04 |
| remove | 10_Smart-Photo-Organizer/.pytest_cache | 可重建測試／編譯快取 | 4 | 0.01 |
| remove | 10_Smart-Photo-Organizer/__pycache__ | 可重建測試／編譯快取 | 99 | 2.29 |
| remove | 10_Smart-Photo-Organizer/src/__pycache__ | 可重建測試／編譯快取 | 15 | 0.34 |
| remove | 10_Smart-Photo-Organizer/src/smart_photo_organizer/__pycache__ | 可重建測試／編譯快取 | 16 | 0.30 |
| remove | 10_Smart-Photo-Organizer/tests/__pycache__ | 可重建測試／編譯快取 | 52 | 0.87 |
| remove | 12_ClipMask-AI/.pytest_cache | 可重建測試／編譯快取 | 5 | 0.00 |
| remove | 12_ClipMask-AI/clipmask/__pycache__ | 可重建測試／編譯快取 | 1 | 0.00 |
| remove | 12_ClipMask-AI/clipmask/ai/__pycache__ | 可重建測試／編譯快取 | 4 | 0.03 |
| remove | 12_ClipMask-AI/clipmask/export/__pycache__ | 可重建測試／編譯快取 | 2 | 0.01 |
| remove | 12_ClipMask-AI/clipmask/gui/__pycache__ | 可重建測試／編譯快取 | 5 | 0.17 |
| remove | 12_ClipMask-AI/clipmask/media/__pycache__ | 可重建測試／編譯快取 | 2 | 0.01 |
| remove | 12_ClipMask-AI/clipmask/models/__pycache__ | 可重建測試／編譯快取 | 2 | 0.01 |
| remove | 12_ClipMask-AI/clipmask/track/__pycache__ | 可重建測試／編譯快取 | 4 | 0.01 |
| remove | 12_ClipMask-AI/tests/__pycache__ | 可重建測試／編譯快取 | 11 | 0.17 |
| remove | 14_Google-Photos-Takeout-Organizer/.pytest_cache | 可重建測試／編譯快取 | 5 | 0.00 |
| remove | 14_Google-Photos-Takeout-Organizer/src/google_photos_takeout_organizer/__pycache__ | 可重建測試／編譯快取 | 17 | 0.14 |
| remove | 14_Google-Photos-Takeout-Organizer/tests/__pycache__ | 可重建測試／編譯快取 | 2 | 0.10 |
| remove | 15_chainflow-inspector/.pytest_cache | 可重建測試／編譯快取 | 5 | 0.01 |
| remove | 15_chainflow-inspector/__pycache__ | 可重建測試／編譯快取 | 3 | 0.01 |
| remove | 15_chainflow-inspector/chain_fund_tracer/__pycache__ | 可重建測試／編譯快取 | 60 | 1.61 |
| remove | 15_chainflow-inspector/tests/__pycache__ | 可重建測試／編譯快取 | 47 | 0.80 |
| remove | DesktopFramesPlus/Code/Desktop Frames/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 3 | 0.01 |
| remove | DesktopFramesPlus/tools/panel-tests/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 23 | 16.78 |
| remove | DesktopFramesPlus/tools/panel-tests/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 16 | 0.20 |
| remove | DesktopFramesPlus/tools/sandbox/bin/Debug | 非現行入口使用的 Debug 編譯產物 | 7 | 0.27 |
| remove | DesktopFramesPlus/tools/sandbox/obj/Debug | 非現行入口使用的 Debug 編譯產物 | 19 | 0.27 |
| remove | 00_Dev-Control-Center/objects | 空的歷史目錄 | 0 | 0.00 |
| remove | 00_Dev-Control-Center/refs | 空的歷史目錄 | 0 | 0.00 |
| remove | 00_Dev-Control-Center/skills | 空的歷史目錄 | 0 | 0.00 |

另外精確清除 38 筆虛構 GUI 測試歷史，其他索引項目及快照保持。
刪除清單共 964 個檔案，
合計 594.72 MiB；搬移容量不算釋放空間。

10 的 Shell 逾時舊目錄會清除，診斷事實及報告保留。生成器仍可重建合成包。

檔案雜湊清冊與保護項目保存在同目錄 operations.json，執行前重新核對。
