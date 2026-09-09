@echo off
chcp 65001 >nul
title [0] 開發控制中心 - 手帳儀表板
cd /d "%~dp0"
set "PS_HOST=pwsh.exe"
where.exe pwsh.exe >nul 2>&1
if errorlevel 1 set "PS_HOST=powershell.exe"
"%PS_HOST%" -STA -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\gui.ps1" -StartupCheck
if errorlevel 1 (
    echo.
    echo 控制中心啟動前檢查失敗，請閱讀上方錯誤訊息。
    pause
    exit /b 1
)

start "" "%PS_HOST%" -WindowStyle Hidden -STA -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\gui.ps1"
if errorlevel 1 (
    echo.
    echo 無法建立控制中心程序。
    pause
    exit /b 1
)
exit /b 0
