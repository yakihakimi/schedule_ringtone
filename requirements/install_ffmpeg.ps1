# Rules applied
# FFmpeg installation script for Windows
# This script downloads and installs FFmpeg for MP3 conversion

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installing FFmpeg" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check if FFmpeg is already installed
try {
    $ffmpegVersion = ffmpeg -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "FFmpeg is already installed:" -ForegroundColor Green
        $versionLine = $ffmpegVersion | Select-String "ffmpeg version"
        Write-Host $versionLine -ForegroundColor Cyan
        Write-Host ""
        Write-Host "FFmpeg installation is complete!" -ForegroundColor Green
        Read-Host "Press Enter to exit"
        exit 0
    }
} catch {
    # FFmpeg not found, continue with installation
}

Write-Host "FFmpeg not found. Installing FFmpeg..." -ForegroundColor Yellow
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
$tempDir = Join-Path $env:TEMP "ffmpeg_install"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

Write-Host "Downloading FFmpeg..." -ForegroundColor Yellow
Write-Host ""

# Download FFmpeg from official source
$ffmpegUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$zipPath = Join-Path $tempDir "ffmpeg.zip"
$extractPath = Join-Path $tempDir "ffmpeg"

Write-Host "Downloading from: $ffmpegUrl" -ForegroundColor Cyan
Write-Host "Saving to: $zipPath" -ForegroundColor Cyan
Write-Host ""

try {
    # Set security protocol for HTTPS
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download the installer
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $zipPath -UseBasicParsing
    
    if (-not (Test-Path $zipPath)) {
        throw "Download failed"
    }
    
    Write-Host "Download completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download FFmpeg!" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Please download FFmpeg manually from https://ffmpeg.org" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

Write-Host "Extracting FFmpeg..." -ForegroundColor Yellow
Write-Host ""

try {
    # Extract the zip file
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    
    # Find the extracted folder (it has a version number in the name)
    $ffmpegFolder = Get-ChildItem -Path $tempDir -Directory -Name "ffmpeg-*" | Select-Object -First 1
    $ffmpegFullPath = Join-Path $tempDir $ffmpegFolder
    
    if (-not (Test-Path $ffmpegFullPath)) {
        throw "Extraction failed"
    }
    
    Write-Host "FFmpeg extracted to: $ffmpegFullPath" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to extract FFmpeg!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Install FFmpeg to project directory (no admin privileges needed)
$installDir = Join-Path (Split-Path $PSScriptRoot -Parent) "ffmpeg"
Write-Host "Installing FFmpeg to project directory: $installDir" -ForegroundColor Yellow
Write-Host ""

try {
    # Create the installation directory in project folder
    if (-not (Test-Path $installDir)) {
        Write-Host "Creating installation directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    # Copy FFmpeg files
    Copy-Item -Path "$ffmpegFullPath\bin\*" -Destination "$installDir\bin\" -Recurse -Force
    Copy-Item -Path "$ffmpegFullPath\doc\*" -Destination "$installDir\doc\" -Recurse -Force
    Copy-Item -Path "$ffmpegFullPath\presets\*" -Destination "$installDir\presets\" -Recurse -Force
    
    Write-Host "FFmpeg files copied successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to copy FFmpeg files!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Add FFmpeg to PATH (current session)
$env:Path = "$installDir\bin;" + $env:Path
Write-Host "FFmpeg added to current session PATH" -ForegroundColor Green

# Note: We don't add to system PATH since we're installing to project directory
# The backend server will automatically find FFmpeg in the project directory
Write-Host "FFmpeg will be automatically detected by the backend server" -ForegroundColor Green

# Clean up temporary files
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
try {
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    # Ignore cleanup errors
}

# Wait a moment for the installation to be recognized
Start-Sleep -Seconds 3

# Check if installation was successful
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow

try {
    # Test FFmpeg directly from the installation directory
    $ffmpegExe = Join-Path $installDir "bin\ffmpeg.exe"
    if (Test-Path $ffmpegExe) {
        $ffmpegVersion = & $ffmpegExe -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "FFmpeg installation completed successfully!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "FFmpeg version:" -ForegroundColor Cyan
            $versionLine = $ffmpegVersion | Select-String "ffmpeg version"
            Write-Host $versionLine -ForegroundColor White
            Write-Host ""
            Write-Host "FFmpeg is now ready for MP3 conversion!" -ForegroundColor Green
            Write-Host "Installation path: $installDir\bin" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "The backend server will automatically find FFmpeg at this location." -ForegroundColor Green
            Write-Host ""
        } else {
            throw "FFmpeg executable failed to run"
        }
    } else {
        throw "FFmpeg executable not found"
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "FFmpeg installation may have failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try the following:" -ForegroundColor Yellow
    Write-Host "1. Check if FFmpeg was installed in $installDir\bin" -ForegroundColor White
    Write-Host "2. Manually download and install from https://ffmpeg.org" -ForegroundColor White
    Write-Host "3. Run this installation script again" -ForegroundColor White
    Write-Host ""
}

Read-Host "Press Enter to exit"
