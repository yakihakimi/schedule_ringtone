@echo off
REM Rules applied
REM Installation script for npm requirements
REM This script installs all required npm packages for the ringtone frontend

echo ========================================
echo Installing NPM Requirements
echo ========================================
echo.

REM Check if Node.js is available
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo.
    echo Attempting to install Node.js automatically...
    echo.
    call install_nodejs.bat
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Failed to install Node.js automatically!
        echo Please install Node.js manually from https://nodejs.org
        pause
        exit /b 1
    )
    echo.
    echo Node.js installation completed. Continuing with npm requirements...
    echo.
)

echo Node.js version:
node --version
echo.

REM Check if npm is available
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: npm is not available
    echo Please ensure npm is installed with Node.js
    pause
    exit /b 1
)

echo npm version:
npm --version
echo.

REM Check if package.json exists (from requirements directory)
if not exist "..\package.json" (
    echo ERROR: package.json not found in parent directory
    echo Please run this script from the requirements directory
    pause
    exit /b 1
)

echo Found package.json
echo.

REM Install dependencies with verbose output
echo Installing npm dependencies...
echo.
cd ..
npm install --verbose

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo NPM Installation completed successfully!
    echo ========================================
    echo.
    echo Installed packages:
    npm list --depth=0
    echo.
    echo Available scripts:
    echo   npm start     - Start development server
    echo   npm build     - Build for production
    echo   npm test      - Run tests
    echo.
) else (
    echo.
    echo ========================================
    echo NPM Installation failed!
    echo ========================================
    echo Please check the error messages above.
    echo.
    echo Common solutions:
    echo   1. Clear npm cache: npm cache clean --force
    echo   2. Delete node_modules and package-lock.json, then run npm install
    echo   3. Check your internet connection
    echo   4. Try using a different npm registry
)

echo.
pause
