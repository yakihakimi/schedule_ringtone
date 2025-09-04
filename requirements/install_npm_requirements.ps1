# Rules applied
# Installation script for npm requirements
# This script installs all required npm packages for the ringtone frontend

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installing NPM Requirements" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Node.js is available
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js not found"
    }
    Write-Host "Node.js version: $nodeVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if npm is available
try {
    $npmVersion = npm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "npm not found"
    }
    Write-Host "npm version: $npmVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: npm is not available" -ForegroundColor Red
    Write-Host "Please ensure npm is installed with Node.js" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Check if package.json exists (from requirements directory)
if (-not (Test-Path "..\package.json")) {
    Write-Host "ERROR: package.json not found in parent directory" -ForegroundColor Red
    Write-Host "Please run this script from the requirements directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Found package.json" -ForegroundColor Green
Write-Host ""

# Install dependencies with verbose output
Write-Host "Installing npm dependencies..." -ForegroundColor Yellow
Write-Host ""

try {
    Set-Location ..
    npm install --verbose
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "NPM Installation completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Installed packages:" -ForegroundColor Cyan
        npm list --depth=0
        Write-Host ""
        Write-Host "Available scripts:" -ForegroundColor Cyan
        Write-Host "  npm start     - Start development server" -ForegroundColor White
        Write-Host "  npm build     - Build for production" -ForegroundColor White
        Write-Host "  npm test      - Run tests" -ForegroundColor White
        Write-Host ""
    } else {
        throw "Installation failed"
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "NPM Installation failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "  1. Clear npm cache: npm cache clean --force" -ForegroundColor White
    Write-Host "  2. Delete node_modules and package-lock.json, then run npm install" -ForegroundColor White
    Write-Host "  3. Check your internet connection" -ForegroundColor White
    Write-Host "  4. Try using a different npm registry" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"
