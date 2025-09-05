@echo off
REM Rules applied
REM Test script to diagnose installation issues

echo ========================================
echo Installation Issues Diagnostic Tool
echo ========================================
echo.

echo Checking current directory...
echo Current directory: %CD%
echo Script directory: %~dp0
echo.

echo Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Node.js is installed:
    node --version
    echo.
    echo Checking npm...
    npm --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✓ npm is installed:
        npm --version
    ) else (
        echo ✗ npm is not working
    )
) else (
    echo ✗ Node.js is not installed or not in PATH
    echo.
    echo Checking common installation paths...
    if exist "C:\Program Files\nodejs\node.exe" (
        echo Found Node.js at: C:\Program Files\nodejs\
    ) else if exist "C:\Program Files (x86)\nodejs\node.exe" (
        echo Found Node.js at: C:\Program Files (x86)\nodejs\
    ) else (
        echo Node.js not found in common installation paths
    )
)

echo.
echo Checking FFmpeg installation...
ffmpeg -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ FFmpeg is installed:
    ffmpeg -version 2>&1 | findstr "ffmpeg version"
) else (
    echo ✗ FFmpeg is not installed or not in PATH
    echo.
    echo Checking common installation paths...
    if exist "C:\Program Files\ffmpeg\bin\ffmpeg.exe" (
        echo Found FFmpeg at: C:\Program Files\ffmpeg\bin\
    ) else if exist "C:\ffmpeg\bin\ffmpeg.exe" (
        echo Found FFmpeg at: C:\ffmpeg\bin\
    ) else (
        echo FFmpeg not found in common installation paths
    )
)

echo.
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Python is installed:
    python --version
) else (
    echo ✗ Python is not installed or not in PATH
)

echo.
echo Checking project structure...
if exist "package.json" (
    echo ✓ package.json found
) else (
    echo ✗ package.json not found
)

if exist "backend\requirements.txt" (
    echo ✓ backend\requirements.txt found
) else (
    echo ✗ backend\requirements.txt not found
)

if exist "requirements\install_nodejs.bat" (
    echo ✓ requirements\install_nodejs.bat found
) else (
    echo ✗ requirements\install_nodejs.bat not found
)

if exist "requirements\install_ffmpeg.bat" (
    echo ✓ requirements\install_ffmpeg.bat found
) else (
    echo ✗ requirements\install_ffmpeg.bat not found
)

echo.
echo ========================================
echo Diagnostic Complete
echo ========================================
echo.
echo If you see any ✗ marks above, those components need to be installed.
echo.
echo To fix issues:
echo 1. Run requirements\install_all_requirements.bat as Administrator
echo 2. Or install components individually:
echo    - requirements\install_nodejs.bat
echo    - requirements\install_ffmpeg.bat
echo    - requirements\install_requirements.bat
echo.
pause
