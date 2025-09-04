@echo off
REM Rules applied
REM Start script for Ringtone Creator App
REM This batch file starts both backend and frontend servers

echo.
echo ========================================
echo    🎵 Ringtone Creator App
echo ========================================
echo.
echo Starting Backend Server First...
echo.
start "Ringtone Backend Server" cmd /k "start_backend.bat"
echo Backend server starting in new window...
echo Waiting 5 seconds for backend to initialize...
timeout /t 5 /nobreak >nul
echo.
echo Starting Frontend App...
echo.

REM Navigate to the main directory (files are now in root)
cd /d "%~dp0"

REM Check if package.json exists
if not exist "package.json" (
    echo ERROR: package.json not found!
    echo Please make sure you're in the correct directory.
    echo.
    pause
    exit /b 1
)

REM Check if node_modules exists, if not install dependencies
if not exist "node_modules" (
    echo Installing dependencies...
    echo.
    echo Attempting to install npm dependencies...
    call requirements\install_npm_requirements.bat
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies!
        echo.
        pause
        exit /b 1
    )
    echo.
)

REM Start the development server
echo Starting React development server...
echo.
echo The app will open in your browser at: http://localhost:3000
echo Backend server is running at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the frontend server
echo Backend server will continue running in its own window
echo.

npm start

REM If npm start fails, try to install requirements and retry
if errorlevel 1 (
    echo.
    echo ERROR: Failed to start the development server!
    echo Attempting to install missing requirements...
    echo.
    call requirements\install_npm_requirements.bat
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install requirements!
        echo Please check the error messages above.
        echo.
        pause
        exit /b 1
    )
    echo.
    echo Retrying to start the development server...
    echo.
    npm start
    if errorlevel 1 (
        echo.
        echo ERROR: Still failed to start after installing requirements!
        echo.
        pause
    )
)
