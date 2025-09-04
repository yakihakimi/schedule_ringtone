# Rules applied
Write-Host "Starting Ringtone Creator Backend Server with System Python..." -ForegroundColor Green
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

Write-Host "Using system Python for pydub compatibility..." -ForegroundColor Cyan
Write-Host ""

# Navigate to backend directory
Set-Location "backend"

# Check if Python requirements are installed
Write-Host "Checking Python requirements..." -ForegroundColor Yellow
try {
    python -c "import flask, flask_cors, pydub, pygame" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Requirements missing"
    }
} catch {
    Write-Host ""
    Write-Host "WARNING: Some Python requirements are missing!" -ForegroundColor Yellow
    Write-Host "Attempting to install requirements..." -ForegroundColor Cyan
    Write-Host ""
    try {
        & "..\requirements\install_requirements.ps1"
        if ($LASTEXITCODE -ne 0) {
            throw "Installation failed"
        }
    } catch {
        Write-Host ""
        Write-Host "ERROR: Failed to install Python requirements!" -ForegroundColor Red
        Write-Host "Please check the error messages above." -ForegroundColor Yellow
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host ""
}

Write-Host ""
Write-Host "Starting Flask server with system Python..." -ForegroundColor Green
Write-Host "Server will be available at: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Using system Python to ensure pydub works for MP3 conversion" -ForegroundColor Yellow
Write-Host ""

# Start the server with system Python
try {
    python server.py
} catch {
    Write-Host "Error: Failed to start server: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
