# Rules applied
# Script to install ffmpeg for pydub audio conversion

Write-Host "🔧 Installing ffmpeg for pydub audio conversion..." -ForegroundColor Green
Write-Host ""

# Check if ffmpeg is already installed
try {
    $ffmpegVersion = ffmpeg -version 2>&1
    if ($ffmpegVersion -match "ffmpeg version") {
        Write-Host "✅ ffmpeg is already installed!" -ForegroundColor Green
        Write-Host $ffmpegVersion -ForegroundColor Cyan
        exit 0
    }
} catch {
    Write-Host "ℹ️ ffmpeg not found, proceeding with installation..." -ForegroundColor Yellow
}

Write-Host "📥 Installing ffmpeg using winget..." -ForegroundColor Yellow

try {
    # Try to install using winget (Windows Package Manager)
    winget install Gyan.FFmpeg
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ffmpeg installed successfully using winget!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🔄 Please restart your terminal/PowerShell to use ffmpeg" -ForegroundColor Yellow
        Write-Host "💡 After restart, run the backend again to test MP3 conversion" -ForegroundColor Cyan
    } else {
        throw "winget installation failed"
    }
} catch {
    Write-Host "❌ winget installation failed. Trying alternative method..." -ForegroundColor Red
    
    Write-Host ""
    Write-Host "📋 Manual Installation Instructions:" -ForegroundColor Yellow
    Write-Host "1. Download ffmpeg from: https://ffmpeg.org/download.html" -ForegroundColor White
    Write-Host "2. Extract to a folder (e.g., C:\ffmpeg)" -ForegroundColor White
    Write-Host "3. Add the bin folder to your PATH environment variable" -ForegroundColor White
    Write-Host "4. Restart your terminal and test with: ffmpeg -version" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 Alternative: Use Chocolatey: choco install ffmpeg" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
