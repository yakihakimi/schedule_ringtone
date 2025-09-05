@echo off
REM Rules applied
REM Complete installation script for the ringtone project
REM This script installs Python, Node.js, FFmpeg, and all requirements

echo ========================================
echo Ringtone Project - Complete Installation
echo ========================================
echo.
echo This script will install:
echo   - Python 3.13+ (if not installed)
echo   - Node.js LTS (if not installed)
echo   - FFmpeg (if not installed)
echo   - Python packages (Flask, pydub, pygame, etc.)
echo   - NPM packages (React, TypeScript, etc.)
echo.
echo Please ensure you have:
echo   - Internet connection
echo   - Administrator privileges (recommended)
echo.
pause
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

REM Install Python requirements (includes Python and FFmpeg installation if needed)
echo ========================================
echo Installing Python Requirements
echo ========================================
echo.

call "%~dp0install_requirements.bat"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Python requirements installation failed
    echo Please check the error messages above
    echo.
    echo This may be due to:
    echo   - Missing Python installation
    echo   - Missing FFmpeg for MP3 conversion
    echo   - Network connectivity issues
    echo   - Permission problems
    echo.
    pause
    exit /b 1
)

REM Install npm requirements (includes Node.js installation if needed)
echo.
echo ========================================
echo Installing NPM Requirements
echo ========================================
echo.

call "%~dp0install_npm_requirements.bat"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: NPM requirements installation failed
    echo Please check the error messages above
    echo.
    echo This may be due to:
    echo   - Missing Node.js installation
    echo   - Network connectivity issues
    echo   - Permission problems
    echo   - Corrupted npm cache
    echo.
    echo Try running: npm cache clean --force
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo All requirements have been installed successfully:
echo   ✓ Python 3.13+ and packages
echo   ✓ Node.js LTS and npm packages
echo   ✓ FFmpeg for MP3 conversion
echo.
echo To start the project:
echo   1. Start the backend: cd backend ^&^& python server.py
echo   2. Start the frontend: npm start
echo.
echo Or use the provided start scripts:
echo   - start_backend.bat (starts backend server)
echo   - start_app.bat (starts both backend and frontend)
echo.
echo The ringtone app is now ready to use!
echo.
pause
