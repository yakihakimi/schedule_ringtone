# Rules applied
# Node.js installation script for Windows
# This script downloads and installs Node.js if it's not already installed

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installing Node.js" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if Node.js is already installed
try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Node.js is already installed:" -ForegroundColor Green
        Write-Host $nodeVersion -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Checking npm..." -ForegroundColor Yellow
        $npmVersion = npm --version 2>&1
        Write-Host $npmVersion -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Node.js installation is complete!" -ForegroundColor Green
        Read-Host "Press Enter to exit"
        exit 0
    }
} catch {
    # Node.js not found, continue with installation
}

Write-Host "Node.js not found. Installing Node.js..." -ForegroundColor Yellow
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
$tempDir = Join-Path $env:TEMP "nodejs_install"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

Write-Host "Downloading Node.js installer..." -ForegroundColor Yellow
Write-Host ""

# Download Node.js LTS version for Windows x64
$nodejsUrl = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
$installerPath = Join-Path $tempDir "nodejs-installer.msi"

Write-Host "Downloading from: $nodejsUrl" -ForegroundColor Cyan
Write-Host "Saving to: $installerPath" -ForegroundColor Cyan
Write-Host ""

try {
    # Set security protocol for HTTPS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download the installer
    Invoke-WebRequest -Uri $nodejsUrl -OutFile $installerPath -UseBasicParsing
    
    if (-not (Test-Path $installerPath)) {
        throw "Download failed"
    }
    
    Write-Host "Download completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download Node.js installer!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Please download Node.js manually from https://nodejs.org" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

Write-Host "Installing Node.js..." -ForegroundColor Yellow
Write-Host "This may take a few minutes. Please wait..." -ForegroundColor Yellow
Write-Host ""

try {
    # Install Node.js silently
    $process = Start-Process -FilePath "msiexec" -ArgumentList "/i", "`"$installerPath`"", "/quiet", "/norestart" -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        throw "Installation failed with exit code: $($process.ExitCode)"
    }
    
    Write-Host "Installation completed!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to install Node.js!" -ForegroundColor Red
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
Start-Sleep -Seconds 5

# Check if installation was successful
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow

try {
    $nodeVersion = node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Node.js installation completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Node.js version:" -ForegroundColor Cyan
        Write-Host $nodeVersion -ForegroundColor White
        Write-Host ""
        Write-Host "npm version:" -ForegroundColor Cyan
        $npmVersion = npm --version 2>&1
        Write-Host $npmVersion -ForegroundColor White
        Write-Host ""
        Write-Host "Node.js is now ready to use!" -ForegroundColor Green
        Write-Host ""
    } else {
        throw "Node.js not found after installation"
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Node.js installation may have failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try the following:" -ForegroundColor Yellow
    Write-Host "1. Restart your command prompt or PowerShell" -ForegroundColor White
    Write-Host "2. Check if Node.js was installed in Program Files" -ForegroundColor White
    Write-Host "3. Manually download and install from https://nodejs.org" -ForegroundColor White
    Write-Host ""
    Write-Host "If you just installed Node.js, you may need to restart your terminal." -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit"
