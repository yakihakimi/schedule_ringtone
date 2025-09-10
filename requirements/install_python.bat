@echo off
REM Rules applied
REM Python installation script for Windows
REM This script downloads and installs Python if it's not already installed

echo ========================================
echo Installing Python
echo ========================================
echo.

REM Check if Python is already installed
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Python is already installed:
    python --version
    echo.
    echo Checking pip...
    pip --version
    echo.
    echo Python installation is complete!
    goto :end
)

echo Python not found. Installing Python...
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
set TEMP_DIR=%TEMP%\python_install
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Downloading Python installer...
echo.

REM Download Python 3.12.4 for Windows x64
REM Using the official Python download URL
set PYTHON_URL=https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe
set INSTALLER_PATH=%TEMP_DIR%\python-installer.exe

echo Downloading from: %PYTHON_URL%
echo Saving to: %INSTALLER_PATH%
echo.

REM Try to download using PowerShell (more reliable than curl on Windows)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%INSTALLER_PATH%' -UseBasicParsing}"

if not exist "%INSTALLER_PATH%" (
    echo ERROR: Failed to download Python installer!
    echo Please check your internet connection and try again.
    echo.
    echo Alternative: Please download Python manually from https://python.org
    echo.
    pause
    exit /b 1
)

echo Download completed successfully!
echo.

echo Installing Python...
echo This may take a few minutes. Please wait...
echo.

REM Install Python with pip and add to PATH
"%INSTALLER_PATH%" /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 Include_test=0

REM Wait for installation to complete
echo Waiting for installation to complete...
timeout /t 60 /nobreak >nul

REM Clean up installer
del "%INSTALLER_PATH%" >nul 2>&1
rmdir "%TEMP_DIR%" >nul 2>&1

REM Refresh environment variables
echo Refreshing environment variables...
call refreshenv >nul 2>&1

REM Check if installation was successful
echo.
echo Verifying installation...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Python installation completed successfully!
    echo ========================================
    echo.
    echo Python version:
    python --version
    echo.
    echo pip version:
    pip --version
    echo.
    echo Python is now ready to use!
    echo.
) else (
    echo.
    echo ========================================
    echo Python installation may have failed!
    echo ========================================
    echo.
    echo Please try the following:
    echo 1. Restart your command prompt or PowerShell
    echo 2. Check if Python was installed in Program Files
    echo 3. Manually download and install from https://python.org
    echo.
    echo If you just installed Python, you may need to restart your terminal.
    echo.
)

:end
echo.
pause
