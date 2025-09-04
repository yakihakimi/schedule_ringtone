@echo off
REM Rules applied
REM Complete installation script for the ringtone project
REM This script installs both Python and npm requirements

echo ========================================
echo Ringtone Project - Complete Installation
echo ========================================
echo.

REM Check if we're in the right directory (from requirements directory)
if not exist "..\package.json" (
    echo ERROR: package.json not found in parent directory
    echo Please run this script from the requirements directory
    pause
    exit /b 1
)

if not exist "..\backend\requirements.txt" (
    echo ERROR: backend\requirements.txt not found in parent directory
    echo Please run this script from the requirements directory
    pause
    exit /b 1
)

echo Project structure verified
echo.

REM Install Python requirements (includes Python installation if needed)
echo ========================================
echo Installing Python Requirements
echo ========================================
echo.

call install_requirements.bat
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Python requirements installation failed
    echo Please check the error messages above
    pause
    exit /b 1
)

REM Install npm requirements (includes Node.js installation if needed)
echo.
echo ========================================
echo Installing NPM Requirements
echo ========================================
echo.

call install_npm_requirements.bat
if %errorlevel% neq 0 (
    echo.
    echo ERROR: NPM requirements installation failed
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Both Python and npm requirements have been installed successfully.
echo.
echo To start the project:
echo   1. Start the backend: cd backend ^&^& python server.py
echo   2. Start the frontend: npm start
echo.
echo Or use the provided start scripts:
echo   - start_backend.bat
echo   - start_app.bat
echo.
pause
