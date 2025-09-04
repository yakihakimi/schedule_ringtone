@echo off
REM Rules applied
REM Node.js installation script for Windows
REM This script downloads and installs Node.js if it's not already installed

echo ========================================
echo Installing Node.js
echo ========================================
echo.

REM Check if Node.js is already installed
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js is already installed:
    node --version
    echo.
    echo Checking npm...
    npm --version
    echo.
    echo Node.js installation is complete!
    goto :end
)

echo Node.js not found. Installing Node.js...
echo.

REM Check if we have internet connectivity
echo Checking internet connectivity...
ping -n 1 google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No internet connection detected!
    echo Please check your internet connection and try again.
    echo.
    pause
    exit /b 1
)

echo Internet connection verified.
echo.

REM Create temporary directory for download
set TEMP_DIR=%TEMP%\nodejs_install
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Downloading Node.js installer...
echo.

REM Download Node.js LTS version for Windows x64
REM Using the official Node.js download URL
set NODEJS_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
set INSTALLER_PATH=%TEMP_DIR%\nodejs-installer.msi

echo Downloading from: %NODEJS_URL%
echo Saving to: %INSTALLER_PATH%
echo.

REM Try to download using PowerShell (more reliable than curl on Windows)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%NODEJS_URL%' -OutFile '%INSTALLER_PATH%' -UseBasicParsing}"

if not exist "%INSTALLER_PATH%" (
    echo ERROR: Failed to download Node.js installer!
    echo Please check your internet connection and try again.
    echo.
    echo Alternative: Please download Node.js manually from https://nodejs.org
    echo.
    pause
    exit /b 1
)

echo Download completed successfully!
echo.

echo Installing Node.js...
echo This may take a few minutes. Please wait...
echo.

REM Install Node.js silently
msiexec /i "%INSTALLER_PATH%" /quiet /norestart

REM Wait for installation to complete
echo Waiting for installation to complete...
timeout /t 30 /nobreak >nul

REM Clean up installer
del "%INSTALLER_PATH%" >nul 2>&1
rmdir "%TEMP_DIR%" >nul 2>&1

REM Refresh environment variables
echo Refreshing environment variables...
call refreshenv >nul 2>&1

REM Check if installation was successful
echo.
echo Verifying installation...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Node.js installation completed successfully!
    echo ========================================
    echo.
    echo Node.js version:
    node --version
    echo.
    echo npm version:
    npm --version
    echo.
    echo Node.js is now ready to use!
    echo.
) else (
    echo.
    echo ========================================
    echo Node.js installation may have failed!
    echo ========================================
    echo.
    echo Please try the following:
    echo 1. Restart your command prompt or PowerShell
    echo 2. Check if Node.js was installed in Program Files
    echo 3. Manually download and install from https://nodejs.org
    echo.
    echo If you just installed Node.js, you may need to restart your terminal.
    echo.
)

:end
echo.
pause
