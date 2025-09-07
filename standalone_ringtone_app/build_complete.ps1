# Rules applied
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Ringtone Creator - Complete Build" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "This script will build the complete standalone application" -ForegroundColor Cyan
Write-Host "including the executable, frontend, and installer package." -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "backend")) {
    Write-Host "ERROR: This script must be run from the standalone_ringtone_app directory!" -ForegroundColor Red
    Write-Host "Please navigate to the standalone_ringtone_app folder and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 1: Build the standalone application
Write-Host "Step 1: Building standalone application..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
try {
    & ".\build_standalone.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }
    Write-Host "✅ Standalone application built successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to build standalone application: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 2: Install FFmpeg
Write-Host "Step 2: Installing FFmpeg..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
try {
    & ".\install_ffmpeg.ps1"
    Write-Host "✅ FFmpeg installation completed!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ FFmpeg installation had issues, but continuing..." -ForegroundColor Yellow
}

Write-Host ""

# Step 3: Create installer
Write-Host "Step 3: Creating installer package..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
try {
    & ".\create_installer.ps1"
    if ($LASTEXITCODE -ne 0) {
        throw "Installer creation failed"
    }
    Write-Host "✅ Installer package created successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create installer package: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 4: Create distribution package
Write-Host "Step 4: Creating distribution package..." -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
try {
    & ".\create_installer_package.bat"
    if ($LASTEXITCODE -ne 0) {
        throw "Distribution package creation failed"
    }
    Write-Host "✅ Distribution package created successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create distribution package: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Final summary
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  BUILD COMPLETE!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Your standalone Ringtone Creator application is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  📁 ringtone_backend.exe (Main application)" -ForegroundColor White
Write-Host "  📁 start_ringtone_app.bat (Launcher)" -ForegroundColor White
Write-Host "  📁 frontend/ (Web interface)" -ForegroundColor White
Write-Host "  📁 ffmpeg/ (Audio processing tools)" -ForegroundColor White
Write-Host "  📁 RingtoneCreator_Standalone.zip (Distribution package)" -ForegroundColor White
Write-Host "  📁 install.bat (Installer script)" -ForegroundColor White
Write-Host "  📁 README.md (Instructions)" -ForegroundColor White
Write-Host ""
Write-Host "To test the application:" -ForegroundColor Yellow
Write-Host "  1. Double-click: start_ringtone_app.bat" -ForegroundColor White
Write-Host "  2. The app will open at: http://localhost:5000" -ForegroundColor White
Write-Host ""
Write-Host "To distribute:" -ForegroundColor Yellow
Write-Host "  1. Share: RingtoneCreator_Standalone.zip" -ForegroundColor White
Write-Host "  2. Recipients extract and run: install.bat" -ForegroundColor White
Write-Host ""
Write-Host "🎵 Your standalone ringtone creator is ready for distribution!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
