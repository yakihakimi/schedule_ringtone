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

REM Determine the correct working directory
REM If called from project root, change to requirements directory
if exist "package.json" (
    if not exist "requirements" (
        echo ERROR: requirements directory not found
        echo Please run this script from the project root or requirements directory
        pause
        exit /b 1
    )
    echo Changing to requirements directory...
    cd /d "requirements"
) else (
    REM Check if we're already in requirements directory
    if not exist "..\package.json" (
        echo ERROR: package.json not found in parent directory
        echo Please run this script from the project root or requirements directory
        pause
        exit /b 1
    )
    echo Working from requirements directory...
)

REM Verify we can find the required files from requirements directory
if not exist "..\package.json" (
    echo ERROR: package.json not found in parent directory
    echo Please run this script from the project root or requirements directory
    pause
    exit /b 1
)

if not exist "..\backend\requirements.txt" (
    echo ERROR: backend\requirements.txt not found in parent directory
    echo Please run this script from the project root or requirements directory
    pause
    exit /b 1
)

echo Project structure verified
echo.

REM Check what's already installed before attempting installation
echo ========================================
echo Checking Current Installation Status
echo ========================================
echo.

REM Check Python installation
echo Checking Python installation...
python --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo [OK] Python %PYTHON_VERSION% is already installed
    set PYTHON_INSTALLED=1
) else (
    echo [MISSING] Python is not installed or not in PATH
    echo Installing Python now...
    call "install_requirements.bat"
    if %errorlevel% neq 0 (
        echo ERROR: Python installation failed
        pause
        exit /b 1
    )
    echo [OK] Python installation completed
    set PYTHON_INSTALLED=1
)

REM Check Node.js installation
echo Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('node --version 2^>^&1') do set NODE_VERSION=%%i
    echo [OK] Node.js %NODE_VERSION% is already installed
    set NODE_INSTALLED=1
) else (
    echo [MISSING] Node.js is not installed or not in PATH
    echo Installing Node.js now...
    call "install_npm_requirements.bat"
    if %errorlevel% neq 0 (
        echo ERROR: Node.js installation failed
        pause
        exit /b 1
    )
    echo [OK] Node.js installation completed
    set NODE_INSTALLED=1
)

REM Check npm installation
echo Checking npm installation...
npm --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f %%i in ('npm --version 2^>^&1') do set NPM_VERSION=%%i
    echo [OK] npm %NPM_VERSION% is already installed
    set NPM_INSTALLED=1
) else (
    echo [MISSING] npm is not installed or not in PATH
    echo Installing npm now...
    call "install_npm_requirements.bat"
    if %errorlevel% neq 0 (
        echo ERROR: npm installation failed
        pause
        exit /b 1
    )
    echo [OK] npm installation completed
    set NPM_INSTALLED=1
)

REM Check FFmpeg installation
echo Checking FFmpeg installation...
ffmpeg -version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] FFmpeg is already installed in PATH
    set FFMPEG_INSTALLED=1
) else (
    REM Check if FFmpeg is in the project directory
    if exist "..\ffmpeg\bin\ffmpeg.exe" (
        echo [OK] FFmpeg is already installed in project directory
        set FFMPEG_INSTALLED=1
    ) else (
        echo [MISSING] FFmpeg is not installed or not in PATH
        echo Installing FFmpeg now...
        call "install_requirements.bat"
        if %errorlevel% neq 0 (
            echo ERROR: FFmpeg installation failed
            pause
            exit /b 1
        )
        echo [OK] FFmpeg installation completed
        set FFMPEG_INSTALLED=1
    )
)

REM Check if Python packages are installed
if %PYTHON_INSTALLED% equ 1 (
    echo Checking Python packages...
    python -c "import flask, pydub, pygame" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Required Python packages are already installed
        set PYTHON_PACKAGES_INSTALLED=1
    ) else (
        echo [MISSING] Some Python packages are missing
        echo Installing Python packages now...
        call "install_requirements.bat"
        if %errorlevel% neq 0 (
            echo ERROR: Python packages installation failed
            pause
            exit /b 1
        )
        echo [OK] Python packages installation completed
        set PYTHON_PACKAGES_INSTALLED=1
    )
) else (
    set PYTHON_PACKAGES_INSTALLED=0
)

REM Check if npm packages are installed
if %NODE_INSTALLED% equ 1 (
    echo Checking npm packages...
    if exist "..\node_modules" (
        echo [OK] npm packages are already installed
        set NPM_PACKAGES_INSTALLED=1
    ) else (
        echo [MISSING] npm packages are not installed
        echo Installing npm packages now...
        call "install_npm_requirements.bat"
        if %errorlevel% neq 0 (
            echo ERROR: npm packages installation failed
            pause
            exit /b 1
        )
        echo [OK] npm packages installation completed
        set NPM_PACKAGES_INSTALLED=1
    )
) else (
    set NPM_PACKAGES_INSTALLED=0
)

echo.
echo ========================================
echo Installation Summary
echo ========================================
echo.
if %PYTHON_INSTALLED% equ 1 echo [OK] Python: Already installed
if %PYTHON_INSTALLED% equ 0 echo [MISSING] Python: Needs installation
if %PYTHON_PACKAGES_INSTALLED% equ 1 echo [OK] Python packages: Already installed
if %PYTHON_PACKAGES_INSTALLED% equ 0 echo [MISSING] Python packages: Needs installation
if %NODE_INSTALLED% equ 1 echo [OK] Node.js: Already installed
if %NODE_INSTALLED% equ 0 echo [MISSING] Node.js: Needs installation
if %NPM_INSTALLED% equ 1 echo [OK] npm: Already installed
if %NPM_INSTALLED% equ 0 echo [MISSING] npm: Needs installation
if %NPM_PACKAGES_INSTALLED% equ 1 echo [OK] npm packages: Already installed
if %NPM_PACKAGES_INSTALLED% equ 0 echo [MISSING] npm packages: Needs installation
if %FFMPEG_INSTALLED% equ 1 echo [OK] FFmpeg: Already installed
if %FFMPEG_INSTALLED% equ 0 echo [MISSING] FFmpeg: Needs installation
echo.

REM Check if everything is already installed
set ALL_INSTALLED=1
if %PYTHON_INSTALLED% neq 1 set ALL_INSTALLED=0
if %PYTHON_PACKAGES_INSTALLED% neq 1 set ALL_INSTALLED=0
if %NODE_INSTALLED% neq 1 set ALL_INSTALLED=0
if %NPM_INSTALLED% neq 1 set ALL_INSTALLED=0
if %NPM_PACKAGES_INSTALLED% neq 1 set ALL_INSTALLED=0
if %FFMPEG_INSTALLED% neq 1 set ALL_INSTALLED=0

if "%ALL_INSTALLED%" equ "1" (
    echo ========================================
    echo All Requirements Already Installed!
    echo ========================================
    echo.
    echo Everything is already set up and ready to use:
    echo   [OK] Python %PYTHON_VERSION% and packages
    echo   [OK] Node.js %NODE_VERSION% and npm %NPM_VERSION%
    echo   [OK] FFmpeg for MP3 conversion
    echo   [OK] All required packages
    echo.
    echo To start the project:
    echo   1. Start the backend: cd ..\backend ^&^& python server.py
    echo   2. Start the frontend: cd .. ^&^& npm start
    echo.
    echo Or use the provided start scripts from the project root:
    echo   - start_backend.bat (starts backend server)
    echo   - start_app.bat (starts both backend and frontend)
    echo.
    echo The ringtone app is now ready to use!
    echo.
    pause
    exit /b 0
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo All requirements are now available:
if %PYTHON_INSTALLED% equ 1 echo   [OK] Python %PYTHON_VERSION% and packages
if %NODE_INSTALLED% equ 1 echo   [OK] Node.js %NODE_VERSION% and npm %NPM_VERSION%
if %FFMPEG_INSTALLED% equ 1 echo   [OK] FFmpeg for MP3 conversion
echo.
echo To start the project:
echo   1. Start the backend: cd ..\backend ^&^& python server.py
echo   2. Start the frontend: cd .. ^&^& npm start
echo.
echo Or use the provided start scripts from the project root:
echo   - start_backend.bat (starts backend server)
echo   - start_app.bat (starts both backend and frontend)
echo.
echo The ringtone app is now ready to use!
echo.
pause
