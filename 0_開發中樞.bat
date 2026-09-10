@echo off
setlocal
cd /d "%~dp0"
set "PS_HOST=pwsh.exe"
where.exe pwsh.exe >nul 2>&1
if errorlevel 1 set "PS_HOST=powershell.exe"

"%PS_HOST%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\dev-hub.ps1"
set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" (
    echo.
    echo Dev Control Center ended with an error. Review the PowerShell output above.
    pause
)
exit /b %EXIT_CODE%
