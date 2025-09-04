# Rules applied
# Python installation script for Windows
# This script downloads and installs Python if it's not already installed

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installing Python" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Python is already installed
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Python is already installed:" -ForegroundColor Green
        Write-Host $pythonVersion -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Checking pip..." -ForegroundColor Yellow
        $pipVersion = pip --version 2>&1
        Write-Host $pipVersion -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Python installation is complete!" -ForegroundColor Green
        Read-Host "Press Enter to exit"
        exit 0
    }
} catch {
    # Python not found, continue with installation
}

Write-Host "Python not found. Installing Python..." -ForegroundColor Yellow
Write-Host ""

# Check if we have internet connectivity
Write-Host "Checking internet connectivity..." -ForegroundColor Yellow
try {
    $ping = Test-Connection -ComputerName "google.com" -Count 1 -Quiet
    if (-not $ping) {
        throw "No internet connection"
    }
    Write-Host "Internet connection verified." -ForegroundColor Green
} catch {
    Write-Host "ERROR: No internet connection detected!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Create temporary directory for download
$tempDir = Join-Path $env:TEMP "python_install"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

Write-Host "Downloading Python installer..." -ForegroundColor Yellow
Write-Host ""

# Download Python 3.13.1 for Windows x64
$pythonUrl = "https://www.python.org/ftp/python/3.13.1/python-3.13.1-amd64.exe"
$installerPath = Join-Path $tempDir "python-installer.exe"

Write-Host "Downloading from: $pythonUrl" -ForegroundColor Cyan
Write-Host "Saving to: $installerPath" -ForegroundColor Cyan
Write-Host ""

try {
    # Set security protocol for HTTPS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download the installer
    Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath -UseBasicParsing
    
    if (-not (Test-Path $installerPath)) {
        throw "Download failed"
    }
    
    Write-Host "Download completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download Python installer!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Please download Python manually from https://python.org" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

Write-Host "Installing Python..." -ForegroundColor Yellow
Write-Host "This may take a few minutes. Please wait..." -ForegroundColor Yellow
Write-Host ""

try {
    # Install Python with pip and add to PATH
    $process = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_pip=1", "Include_test=0" -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        throw "Installation failed with exit code: $($process.ExitCode)"
    }
    
    Write-Host "Installation completed!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to install Python!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Clean up installer
try {
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Force -ErrorAction SilentlyContinue
} catch {
    # Ignore cleanup errors
}

# Refresh environment variables
Write-Host "Refreshing environment variables..." -ForegroundColor Yellow
try {
    # Try to refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
} catch {
    # Ignore refresh errors
}

# Wait a moment for the installation to be recognized
Start-Sleep -Seconds 10

# Check if installation was successful
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow

try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Python installation completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Python version:" -ForegroundColor Cyan
        Write-Host $pythonVersion -ForegroundColor White
        Write-Host ""
        Write-Host "pip version:" -ForegroundColor Cyan
        $pipVersion = pip --version 2>&1
        Write-Host $pipVersion -ForegroundColor White
        Write-Host ""
        Write-Host "Python is now ready to use!" -ForegroundColor Green
        Write-Host ""
    } else {
        throw "Python not found after installation"
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Python installation may have failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try the following:" -ForegroundColor Yellow
    Write-Host "1. Restart your command prompt or PowerShell" -ForegroundColor White
    Write-Host "2. Check if Python was installed in Program Files" -ForegroundColor White
    Write-Host "3. Manually download and install from https://python.org" -ForegroundColor White
    Write-Host ""
    Write-Host "If you just installed Python, you may need to restart your terminal." -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit"
