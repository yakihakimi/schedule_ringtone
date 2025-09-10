# Rules applied
# Installation script for Python requirements
# This script installs all required Python packages for the ringtone project

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installing Python Requirements" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Python is available
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found"
    }
    Write-Host "Python version: $pythonVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Attempting to install Python automatically..." -ForegroundColor Yellow
    Write-Host ""
    try {
        & ".\install_python.ps1"
        if ($LASTEXITCODE -ne 0) {
            throw "Python installation failed"
        }
        Write-Host ""
        Write-Host "Python installation completed. Continuing with Python requirements..." -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host ""
        Write-Host "ERROR: Failed to install Python automatically!" -ForegroundColor Red
        Write-Host "Please install Python 3.12.4 manually from https://python.org" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""

# Check if pip is available
try {
    $pipVersion = pip --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "pip not found"
    }
    Write-Host "pip version: $pipVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: pip is not available" -ForegroundColor Red
    Write-Host "Please ensure pip is installed with Python" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if FFmpeg is available for pydub
Write-Host "Checking FFmpeg for MP3 conversion..." -ForegroundColor Yellow
try {
    $ffmpegVersion = ffmpeg -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg not found"
    }
    Write-Host "FFmpeg is already installed - MP3 conversion ready!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "WARNING: FFmpeg not found - MP3 conversion may not work!" -ForegroundColor Yellow
    Write-Host "Attempting to install FFmpeg automatically..." -ForegroundColor Cyan
    Write-Host ""
    try {
        & ".\install_ffmpeg.ps1"
        if ($LASTEXITCODE -ne 0) {
            throw "FFmpeg installation failed"
        }
        Write-Host ""
        Write-Host "FFmpeg installation completed. MP3 conversion should now work!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host ""
        Write-Host "WARNING: Failed to install FFmpeg automatically!" -ForegroundColor Yellow
        Write-Host "MP3 conversion may not work. You can install FFmpeg manually from https://ffmpeg.org" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host ""
Write-Host "Installing Python requirements from backend\requirements.txt..." -ForegroundColor Yellow
Write-Host ""

try {
    Set-Location ..
    pip install -r backend\requirements.txt --verbose
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Installation completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installed packages:" -ForegroundColor Cyan
        pip list
    } else {
        throw "Installation failed"
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Installation failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"
