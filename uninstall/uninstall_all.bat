@echo off
REM Rules applied
REM Master uninstaller for Node.js and FFmpeg
REM This script runs both uninstallers in sequence

echo ========================================
echo Complete Uninstaller
echo Node.js and FFmpeg Removal Tool
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo WARNING: This script should be run as administrator for complete removal
    echo Some files may not be removed without admin privileges
    echo.
    echo Do you want to continue anyway? (Y/N)
    set /p choice=
    if /i not "%choice%"=="Y" (
        echo Uninstallation cancelled.
        pause
        exit /b 1
    )
)

echo.
echo This will uninstall:
echo - Node.js and npm
echo - FFmpeg
echo.
echo Do you want to proceed? (Y/N)
set /p confirm=
if /i not "%confirm%"=="Y" (
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.
echo Starting complete uninstallation...
echo.

REM Run Node.js uninstaller
echo ========================================
echo Running Node.js Uninstaller...
echo ========================================
call "%~dp0uninstall_nodejs.bat"
if %errorLevel% neq 0 (
    echo WARNING: Node.js uninstallation encountered errors
    echo Error code: %errorLevel%
) else (
    echo Node.js uninstallation completed successfully
)

echo.
echo ========================================
echo Running FFmpeg Uninstaller...
echo ========================================
call "%~dp0uninstall_ffmpeg.bat"
if %errorLevel% neq 0 (
    echo WARNING: FFmpeg uninstallation encountered errors
    echo Error code: %errorLevel%
) else (
    echo FFmpeg uninstallation completed successfully
)

echo.
echo ========================================
echo Complete Uninstallation Summary
echo ========================================
echo.
echo The following components have been uninstalled:
echo - Node.js and npm
echo - FFmpeg
echo.
echo IMPORTANT: Please restart your computer or log out and back in
echo to ensure all environment variables are updated.
echo.
echo Manual cleanup may be required for:
echo - Any remaining installation folders
echo - Environment variable entries
echo - Registry entries
echo - Desktop and start menu shortcuts
echo.
echo If you encounter any issues, please check the individual
echo uninstaller logs or run them separately:
echo - uninstall_nodejs.bat
echo - uninstall_ffmpeg.bat
echo.
pause
