@echo off
REM Rules applied
REM Test script to verify Node.js installation

echo ========================================
echo Testing Node.js Installation
echo ========================================
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
        echo.
        echo ✓ Node.js installation is working correctly!
    ) else (
        echo ✗ npm is not working
        echo Node.js may be installed but npm is not available
    )
) else (
    echo ✗ Node.js is not installed or not in PATH
    echo.
    echo Checking common installation paths...
    if exist "C:\Program Files\nodejs\node.exe" (
        echo Found Node.js at: C:\Program Files\nodejs\
        echo Adding to PATH for this session...
        set "PATH=C:\Program Files\nodejs;%PATH%"
        node --version
    ) else if exist "C:\Program Files (x86)\nodejs\node.exe" (
        echo Found Node.js at: C:\Program Files (x86)\nodejs\
        echo Adding to PATH for this session...
        set "PATH=C:\Program Files (x86)\nodejs;%PATH%"
        node --version
    ) else (
        echo Node.js not found in common installation paths
        echo Please install Node.js or run the installation script
    )
)

echo.
echo ========================================
echo Test Complete
echo ========================================
echo.
pause
