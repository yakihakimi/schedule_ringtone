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
$backendDir = Join-Path $PSScriptRoot "ringtone-app\backend"
Set-Location $backendDir

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
