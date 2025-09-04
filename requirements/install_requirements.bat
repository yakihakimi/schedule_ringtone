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
    echo.
    echo Attempting to install Python automatically...
    echo.
    call install_python.bat
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Failed to install Python automatically!
        echo Please install Python 3.13+ manually from https://python.org
        pause
        exit /b 1
    )
    echo.
    echo Python installation completed. Continuing with Python requirements...
    echo.
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

REM Check if FFmpeg is available for pydub
echo Checking FFmpeg for MP3 conversion...
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo WARNING: FFmpeg not found - MP3 conversion may not work!
    echo Attempting to install FFmpeg automatically...
    echo.
    call install_ffmpeg.bat
    if %errorlevel% neq 0 (
        echo.
        echo WARNING: Failed to install FFmpeg automatically!
        echo MP3 conversion may not work. You can install FFmpeg manually from https://ffmpeg.org
        echo.
    ) else (
        echo.
        echo FFmpeg installation completed. MP3 conversion should now work!
        echo.
    )
) else (
    echo FFmpeg is already installed - MP3 conversion ready!
)

echo.
echo Installing Python requirements from backend\requirements.txt...
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
