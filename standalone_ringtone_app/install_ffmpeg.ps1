# Rules applied
Write-Host "Installing FFmpeg for Standalone Ringtone Creator..." -ForegroundColor Green
Write-Host ""

# Create ffmpeg directory structure
$ffmpegDir = "ffmpeg\bin"
if (-not (Test-Path $ffmpegDir)) {
    New-Item -ItemType Directory -Path $ffmpegDir -Force | Out-Null
    Write-Host "Created FFmpeg directory: $ffmpegDir" -ForegroundColor Green
}

# Check if FFmpeg is already installed
$ffmpegExe = "$ffmpegDir\ffmpeg.exe"
if (Test-Path $ffmpegExe) {
    Write-Host "FFmpeg already exists in standalone app" -ForegroundColor Yellow
    $ffmpegVersion = & $ffmpegExe -version 2>&1 | Select-String "ffmpeg version" | Select-Object -First 1
    Write-Host "FFmpeg version: $ffmpegVersion" -ForegroundColor Green
    Read-Host "Press Enter to continue"
    exit 0
}

Write-Host "FFmpeg not found in standalone app. Downloading..." -ForegroundColor Yellow

# Try to download FFmpeg using winget (Windows Package Manager)
try {
    Write-Host "Attempting to install FFmpeg using winget..." -ForegroundColor Cyan
    winget install "Gyan.FFmpeg" --accept-package-agreements --accept-source-agreements --silent
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "FFmpeg installed successfully via winget" -ForegroundColor Green
        
        # Try to find the installed FFmpeg
        $wingetPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.0-full_build\bin"
        if (Test-Path $wingetPath) {
            Write-Host "Copying FFmpeg from winget installation..." -ForegroundColor Yellow
            Copy-Item -Path "$wingetPath\*" -Destination $ffmpegDir -Force
            Write-Host "FFmpeg copied to standalone app successfully" -ForegroundColor Green
        } else {
            Write-Host "Could not locate winget FFmpeg installation" -ForegroundColor Yellow
        }
    } else {
        throw "winget installation failed"
    }
} catch {
    Write-Host "winget installation failed, trying alternative method..." -ForegroundColor Yellow
    
    # Alternative: Download FFmpeg manually
    try {
        Write-Host "Downloading FFmpeg from official source..." -ForegroundColor Cyan
        
        # Create a temporary directory
        $tempDir = "temp_ffmpeg"
        if (-not (Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        }
        
        # Download FFmpeg (this is a simplified approach - in production you'd want to use the actual download URL)
        $downloadUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
        $zipFile = "$tempDir\ffmpeg.zip"
        
        Write-Host "Downloading FFmpeg from: $downloadUrl" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
        
        if (Test-Path $zipFile) {
            Write-Host "Extracting FFmpeg..." -ForegroundColor Yellow
            Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
            
            # Find the extracted FFmpeg bin directory
            $extractedBin = Get-ChildItem -Path $tempDir -Recurse -Directory -Name "bin" | Select-Object -First 1
            if ($extractedBin) {
                $sourceBin = Join-Path $tempDir $extractedBin
                Copy-Item -Path "$sourceBin\*" -Destination $ffmpegDir -Force
                Write-Host "FFmpeg extracted and copied successfully" -ForegroundColor Green
            }
            
            # Clean up
            Remove-Item -Path $tempDir -Recurse -Force
        }
    } catch {
        Write-Host "Manual download failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install FFmpeg manually:" -ForegroundColor Yellow
        Write-Host "1. Download FFmpeg from: https://ffmpeg.org/download.html" -ForegroundColor White
        Write-Host "2. Extract the files to: $ffmpegDir" -ForegroundColor White
        Write-Host "3. Ensure ffmpeg.exe is in the bin folder" -ForegroundColor White
        Write-Host ""
        Read-Host "Press Enter to continue (you can install FFmpeg later)"
    }
}

# Verify FFmpeg installation
if (Test-Path $ffmpegExe) {
    try {
        $ffmpegVersion = & $ffmpegExe -version 2>&1 | Select-String "ffmpeg version" | Select-Object -First 1
        Write-Host ""
        Write-Host "✅ FFmpeg installed successfully!" -ForegroundColor Green
        Write-Host "Version: $ffmpegVersion" -ForegroundColor Cyan
        Write-Host "Location: $ffmpegExe" -ForegroundColor Cyan
    } catch {
        Write-Host "FFmpeg found but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "⚠️ FFmpeg installation incomplete" -ForegroundColor Yellow
    Write-Host "The application will work but MP3 conversion may not be available" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install FFmpeg manually:" -ForegroundColor Cyan
    Write-Host "1. Download from: https://ffmpeg.org/download.html" -ForegroundColor White
    Write-Host "2. Extract to: $ffmpegDir" -ForegroundColor White
    Write-Host "3. Ensure ffmpeg.exe is in the bin folder" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"
