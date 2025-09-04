# Rules applied
# Complete installation script for the ringtone project
# This script installs both Python and npm requirements

Write-Host "========================================" -ForegroundColor Green
Write-Host "Ringtone Project - Complete Installation" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory (from requirements directory)
if (-not (Test-Path "..\package.json")) {
    Write-Host "ERROR: package.json not found in parent directory" -ForegroundColor Red
    Write-Host "Please run this script from the requirements directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

if (-not (Test-Path "..\backend\requirements.txt")) {
    Write-Host "ERROR: backend\requirements.txt not found in parent directory" -ForegroundColor Red
    Write-Host "Please run this script from the requirements directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Project structure verified" -ForegroundColor Green
Write-Host ""

# Install Python requirements (includes Python installation if needed)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Python Requirements" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    & ".\install_requirements.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "Python requirements installation failed"
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Python requirements installation failed" -ForegroundColor Red
    Write-Host "Please check the error messages above" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Install npm requirements (includes Node.js installation if needed)
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing NPM Requirements" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    & ".\install_npm_requirements.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "NPM requirements installation failed"
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: NPM requirements installation failed" -ForegroundColor Red
    Write-Host "Please check the error messages above" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Both Python and npm requirements have been installed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "To start the project:" -ForegroundColor Cyan
Write-Host "  1. Start the backend: cd backend; python server.py" -ForegroundColor White
Write-Host "  2. Start the frontend: npm start" -ForegroundColor White
Write-Host ""
Write-Host "Or use the provided start scripts:" -ForegroundColor Cyan
Write-Host "  - start_backend.bat" -ForegroundColor White
Write-Host "  - start_app.bat" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
