@echo off
REM Rules applied
echo Starting Ringtone Creator Backend Server with System Python...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.7+ and try again
    pause
    exit /b 1
)

echo Python found. Using system Python for pydub compatibility...
echo.

REM Navigate to backend directory
cd /d "%~dp0backend"

REM Check if Python requirements are installed
echo Checking Python requirements...
python -c "import flask, flask_cors, pydub, pygame" >nul 2>&1
if errorlevel 1 (
    echo.
    echo WARNING: Some Python requirements are missing!
    echo Attempting to install requirements...
    echo.
    call ..\requirements\install_requirements.bat
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install Python requirements!
        echo Please check the error messages above.
        echo.
        pause
        exit /b 1
    )
    echo.
)

echo.
echo Starting Flask server with system Python...
echo Server will be available at: http://localhost:5000
echo Press Ctrl+C to stop the server
echo.
echo Note: Using system Python to ensure pydub works for MP3 conversion
echo.

REM Start the server with system Python
python server.py

pause
