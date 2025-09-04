@echo off
REM Rules applied
REM Installation script for Python requirements
REM This script installs all required Python packages for the ringtone project

echo ========================================
echo Installing Python Requirements
echo ========================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.13+ from https://python.org
    pause
    exit /b 1
)

echo Python version:
python --version
echo.

REM Check if pip is available
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: pip is not available
    echo Please ensure pip is installed with Python
    pause
    exit /b 1
)

echo pip version:
pip --version
echo.

REM Install requirements with verbose output
echo Installing requirements from backend\requirements.txt...
echo.
cd ..
pip install -r backend\requirements.txt --verbose

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Installation completed successfully!
    echo ========================================
    echo.
    echo Installed packages:
    pip list
) else (
    echo.
    echo ========================================
    echo Installation failed!
    echo ========================================
    echo Please check the error messages above.
)

echo.
pause
