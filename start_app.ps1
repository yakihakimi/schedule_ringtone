# Rules applied
# Start script for Ringtone Creator App
# This PowerShell script starts both backend and frontend servers

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    🎵 Ringtone Creator App" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting Backend Server First..." -ForegroundColor Green
Write-Host ""

# Start backend server in new PowerShell window
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendScript = Join-Path $scriptPath "start_backend.ps1"
if (Test-Path $backendScript) {
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& '$backendScript'" -WindowStyle Normal
    Write-Host "Backend server starting in new window..." -ForegroundColor Green
    Write-Host "Waiting 5 seconds for backend to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Write-Host ""
} else {
    Write-Host "WARNING: start_backend.ps1 not found!" -ForegroundColor Yellow
    Write-Host "Backend server will not be started automatically." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Starting Frontend App..." -ForegroundColor Green
Write-Host ""

# Navigate to the main directory (files are now in root)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Check if package.json exists
if (-not (Test-Path "package.json")) {
    Write-Host "ERROR: package.json not found!" -ForegroundColor Red
    Write-Host "Please make sure you're in the correct directory." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 1
}

# Check if node_modules exists, if not install dependencies
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Attempting to install npm dependencies..." -ForegroundColor Cyan
    try {
        & "$scriptPath\requirements\install_npm_requirements.ps1"
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed"
        }
    }
    catch {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to continue"
        exit 1
    }
    Write-Host ""
}

# Start the development server
Write-Host "Starting React development server..." -ForegroundColor Green
Write-Host ""
Write-Host "The app will open in your browser at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend server is running at: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the frontend server" -ForegroundColor Yellow
Write-Host "Backend server will continue running in its own window" -ForegroundColor Yellow
Write-Host ""

try {
    npm start
}
catch {
    Write-Host ""
    Write-Host "ERROR: Failed to start the development server!" -ForegroundColor Red
    Write-Host "Attempting to install missing requirements..." -ForegroundColor Yellow
    Write-Host ""
    try {
        & "$scriptPath\requirements\install_npm_requirements.ps1"
        if ($LASTEXITCODE -ne 0) {
            throw "Requirements installation failed"
        }
        Write-Host ""
        Write-Host "Retrying to start the development server..." -ForegroundColor Green
        Write-Host ""
        npm start
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "ERROR: Still failed to start after installing requirements!" -ForegroundColor Red
            Write-Host ""
            Read-Host "Press Enter to continue"
        }
    }
    catch {
        Write-Host ""
        Write-Host "ERROR: Failed to install requirements!" -ForegroundColor Red
        Write-Host "Please check the error messages above." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to continue"
    }
}
