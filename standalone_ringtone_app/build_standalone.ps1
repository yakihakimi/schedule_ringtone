# Rules applied
Write-Host "Building Standalone Ringtone Creator Application..." -ForegroundColor Green
Write-Host ""

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.7+ and try again" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if PyInstaller is installed
try {
    $pyinstallerVersion = pyinstaller --version 2>&1
    Write-Host "PyInstaller found: $pyinstallerVersion" -ForegroundColor Green
} catch {
    Write-Host "PyInstaller not found. Installing..." -ForegroundColor Yellow
    try {
        pip install pyinstaller --verbose
        Write-Host "PyInstaller installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to install PyInstaller" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

# Check if required packages are installed
Write-Host "Checking required packages..." -ForegroundColor Yellow
$requiredPackages = @("flask", "flask-cors", "pydub", "pygame", "requests", "python-dateutil")
$missingPackages = @()

foreach ($package in $requiredPackages) {
    try {
        python -c "import $($package.Replace('-', '_'))" 2>$null
        if ($LASTEXITCODE -ne 0) {
            $missingPackages += $package
        }
    } catch {
        $missingPackages += $package
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "Installing missing packages: $($missingPackages -join ', ')" -ForegroundColor Yellow
    foreach ($package in $missingPackages) {
        try {
            pip install $package --verbose
        } catch {
            Write-Host "Error: Failed to install $package" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
    }
}

Write-Host "All required packages are installed" -ForegroundColor Green

# Build React frontend
Write-Host ""
Write-Host "Building React frontend..." -ForegroundColor Yellow
Set-Location ".."
try {
    # Check if Node.js is installed
    $nodeVersion = node --version 2>&1
    Write-Host "Node.js found: $nodeVersion" -ForegroundColor Green
    
    # Check if npm is installed
    $npmVersion = npm --version 2>&1
    Write-Host "npm found: $npmVersion" -ForegroundColor Green
    
    # Install dependencies if needed
    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
        npm install --verbose
    }
    
    # Build the React app
    Write-Host "Building React app for production..." -ForegroundColor Yellow
    npm run build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "React frontend built successfully" -ForegroundColor Green
        
        # Copy build files to standalone app
        Write-Host "Copying frontend files to standalone app..." -ForegroundColor Yellow
        Copy-Item -Path "build\*" -Destination "standalone_ringtone_app\frontend\" -Recurse -Force
        Write-Host "Frontend files copied successfully" -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to build React frontend" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "Error building React frontend: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Return to standalone app directory
Set-Location "standalone_ringtone_app"

# Build the Python executable
Write-Host ""
Write-Host "Building Python executable..." -ForegroundColor Yellow
Set-Location "backend"

try {
    # Use the standalone server as the main script
    pyinstaller --onefile --console --name "ringtone_backend" --add-data "taskSchedulerService.py;." --add-data "play_ringtone.py;." server_standalone.py
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Python executable built successfully" -ForegroundColor Green
        
        # Copy executable to parent directory
        Copy-Item -Path "dist\ringtone_backend.exe" -Destination "..\" -Force
        Write-Host "Executable copied to standalone app root" -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to build Python executable" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "Error building Python executable: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Return to standalone app root
Set-Location ".."

# Create launcher script
Write-Host ""
Write-Host "Creating launcher script..." -ForegroundColor Yellow

$launcherScript = @"
# Rules applied
@echo off
title Ringtone Creator - Standalone Application
echo.
echo ========================================
echo   Ringtone Creator - Standalone App
echo ========================================
echo.
echo Starting application...
echo.

REM Check if the executable exists
if not exist "ringtone_backend.exe" (
    echo ERROR: ringtone_backend.exe not found!
    echo Please run build_standalone.ps1 first to build the application.
    echo.
    pause
    exit /b 1
)

REM Start the backend server
echo Starting backend server...
start "Ringtone Backend" ringtone_backend.exe

REM Wait a moment for the server to start
timeout /t 3 /nobreak >nul

REM Open the application in the default browser
echo Opening application in browser...
start http://localhost:5000

echo.
echo Application started successfully!
echo.
echo The application is now running at: http://localhost:5000
echo.
echo To stop the application, close this window or press Ctrl+C
echo.
pause
"@

$launcherScript | Out-File -FilePath "start_ringtone_app.bat" -Encoding ASCII
Write-Host "Launcher script created: start_ringtone_app.bat" -ForegroundColor Green

# Create README for the standalone app
Write-Host ""
Write-Host "Creating README..." -ForegroundColor Yellow

$readmeContent = @"
# Ringtone Creator - Standalone Application

This is a standalone version of the Ringtone Creator application that runs without requiring Python, Node.js, or any other dependencies to be installed on the target system.

## How to Use

1. **Start the Application:**
   - Double-click `start_ringtone_app.bat` to launch the application
   - The application will automatically open in your default web browser

2. **Using the Application:**
   - Upload MP3 or WAV audio files
   - Create custom ringtones by selecting start and end times
   - Schedule ringtones to play at specific times
   - Manage your ringtone library

## Features

- ✅ Standalone executable (no dependencies required)
- ✅ Audio file upload and processing
- ✅ Ringtone creation with custom start/end times
- ✅ Windows Task Scheduler integration
- ✅ MP3 and WAV format support
- ✅ Modern web interface

## File Structure

```
standalone_ringtone_app/
├── ringtone_backend.exe          # Main application executable
├── start_ringtone_app.bat        # Launcher script
├── frontend/                     # Web interface files
├── ringtones/                    # Created ringtones storage
│   ├── wav_ringtones/
│   └── mp3_ringtones/
├── original_sound/               # Uploaded audio files
└── ffmpeg/                       # Audio processing tools
```

## Troubleshooting

- If the application doesn't start, make sure no other application is using port 5000
- If audio conversion fails, ensure FFmpeg is properly installed
- Check the console output for any error messages

## System Requirements

- Windows 10 or later
- At least 100MB free disk space
- Internet connection (for initial setup only)

## Support

For issues or questions, please check the console output for error messages.
"@

$readmeContent | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "README created: README.md" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Standalone App Build Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  - ringtone_backend.exe (Main executable)" -ForegroundColor White
Write-Host "  - start_ringtone_app.bat (Launcher script)" -ForegroundColor White
Write-Host "  - frontend/ (Web interface)" -ForegroundColor White
Write-Host "  - README.md (Instructions)" -ForegroundColor White
Write-Host ""
Write-Host "To run the application:" -ForegroundColor Yellow
Write-Host "  1. Double-click start_ringtone_app.bat" -ForegroundColor White
Write-Host "  2. The app will open in your browser at http://localhost:5000" -ForegroundColor White
Write-Host ""
Write-Host "The standalone app is ready for distribution!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
