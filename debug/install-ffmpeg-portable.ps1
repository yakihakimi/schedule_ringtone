# Rules applied
# Script to install FFmpeg in the working directory for portable installation

Write-Host "🔧 Installing FFmpeg in working directory for portable installation..." -ForegroundColor Green
Write-Host ""

# Get the project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot
$ffmpegDir = Join-Path $projectRoot "ffmpeg"
$ffmpegBinDir = Join-Path $ffmpegDir "bin"

Write-Host "📁 Project root: $projectRoot" -ForegroundColor Cyan
Write-Host "📁 FFmpeg directory: $ffmpegDir" -ForegroundColor Cyan
Write-Host "📁 FFmpeg bin directory: $ffmpegBinDir" -ForegroundColor Cyan
Write-Host ""

# Check if ffmpeg is already installed in the working directory
if (Test-Path (Join-Path $ffmpegBinDir "ffmpeg.exe")) {
    Write-Host "✅ FFmpeg is already installed in working directory!" -ForegroundColor Green
    Write-Host "📁 Location: $ffmpegBinDir" -ForegroundColor Cyan
    
    # Test the installation
    try {
        $version = & (Join-Path $ffmpegBinDir "ffmpeg.exe") -version 2>&1 | Select-Object -First 1
        Write-Host "🔍 Version: $version" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "💡 The backend should now be able to find FFmpeg automatically" -ForegroundColor Green
        exit 0
    } catch {
        Write-Host "⚠️ FFmpeg found but may not be working properly" -ForegroundColor Yellow
    }
}

Write-Host "📥 Downloading FFmpeg for portable installation..." -ForegroundColor Yellow

# Create ffmpeg directory
if (-not (Test-Path $ffmpegDir)) {
    New-Item -ItemType Directory -Path $ffmpegDir -Force | Out-Null
    Write-Host "📁 Created directory: $ffmpegDir" -ForegroundColor Cyan
}

# Download FFmpeg
$downloadUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
$zipFile = Join-Path $ffmpegDir "ffmpeg.zip"
$extractDir = Join-Path $ffmpegDir "temp"

try {
    Write-Host "🌐 Downloading from: $downloadUrl" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "✅ Download completed" -ForegroundColor Green
    
    Write-Host "📦 Extracting FFmpeg..." -ForegroundColor Yellow
    Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
    
    # Find the extracted folder (it might have a version-specific name)
    $extractedFolders = Get-ChildItem -Path $extractDir -Directory
    if ($extractedFolders.Count -gt 0) {
        $sourceDir = $extractedFolders[0].FullName
        $sourceBinDir = Join-Path $sourceDir "bin"
        
        if (Test-Path $sourceBinDir) {
            # Copy bin directory to our target location
            Copy-Item -Path $sourceBinDir -Destination $ffmpegBinDir -Recurse -Force
            Write-Host "✅ FFmpeg extracted to: $ffmpegBinDir" -ForegroundColor Green
            
            # Clean up
            Remove-Item -Path $extractDir -Recurse -Force
            Remove-Item -Path $zipFile -Force
            
            # Test the installation
            try {
                $version = & (Join-Path $ffmpegBinDir "ffmpeg.exe") -version 2>&1 | Select-Object -First 1
                Write-Host "🔍 Version: $version" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "🎉 FFmpeg installed successfully in working directory!" -ForegroundColor Green
                Write-Host "📁 Location: $ffmpegBinDir" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "💡 The backend will now automatically find FFmpeg" -ForegroundColor Green
                Write-Host "💡 No system PATH changes required" -ForegroundColor Green
                
            } catch {
                Write-Host "❌ FFmpeg installation failed - executable not working" -ForegroundColor Red
                exit 1
            }
            
        } else {
            Write-Host "❌ Could not find bin directory in extracted files" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Could not find extracted FFmpeg directory" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Download or extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Manual Installation Instructions:" -ForegroundColor Yellow
    Write-Host "1. Download FFmpeg from: https://ffmpeg.org/download.html" -ForegroundColor White
    Write-Host "2. Extract to: $ffmpegDir" -ForegroundColor White
    Write-Host "3. Ensure the bin folder contains ffmpeg.exe" -ForegroundColor White
    Write-Host "4. The backend will automatically detect it" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

