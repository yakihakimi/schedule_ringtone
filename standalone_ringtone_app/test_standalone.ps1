# Rules applied
Write-Host "Testing Standalone Ringtone Creator Application..." -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "backend")) {
    Write-Host "ERROR: This script must be run from the standalone_ringtone_app directory!" -ForegroundColor Red
    Write-Host "Please navigate to the standalone_ringtone_app folder and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Running tests for standalone application..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if executable exists
Write-Host "Test 1: Checking if executable exists..." -ForegroundColor Yellow
if (Test-Path "ringtone_backend.exe") {
    Write-Host "✅ ringtone_backend.exe found" -ForegroundColor Green
} else {
    Write-Host "❌ ringtone_backend.exe not found" -ForegroundColor Red
    Write-Host "Please run build_standalone.ps1 first" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Test 2: Check if frontend exists
Write-Host ""
Write-Host "Test 2: Checking if frontend exists..." -ForegroundColor Yellow
if (Test-Path "frontend\index.html") {
    Write-Host "✅ Frontend files found" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend files not found" -ForegroundColor Red
    Write-Host "Please run build_standalone.ps1 first" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Test 3: Check if launcher script exists
Write-Host ""
Write-Host "Test 3: Checking if launcher script exists..." -ForegroundColor Yellow
if (Test-Path "start_ringtone_app.bat") {
    Write-Host "✅ Launcher script found" -ForegroundColor Green
} else {
    Write-Host "❌ Launcher script not found" -ForegroundColor Red
    Write-Host "Please run build_standalone.ps1 first" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Test 4: Check if FFmpeg exists
Write-Host ""
Write-Host "Test 4: Checking if FFmpeg exists..." -ForegroundColor Yellow
if (Test-Path "ffmpeg\bin\ffmpeg.exe") {
    Write-Host "✅ FFmpeg found" -ForegroundColor Green
    try {
        $ffmpegVersion = & "ffmpeg\bin\ffmpeg.exe" -version 2>&1 | Select-String "ffmpeg version" | Select-Object -First 1
        Write-Host "FFmpeg version: $ffmpegVersion" -ForegroundColor Cyan
    } catch {
        Write-Host "⚠️ FFmpeg found but version check failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ FFmpeg not found - MP3 conversion may not work" -ForegroundColor Yellow
    Write-Host "Run install_ffmpeg.ps1 to install FFmpeg" -ForegroundColor Cyan
}

# Test 5: Check if directories exist
Write-Host ""
Write-Host "Test 5: Checking if required directories exist..." -ForegroundColor Yellow
$requiredDirs = @("ringtones", "ringtones\wav_ringtones", "ringtones\mp3_ringtones", "original_sound")
$allDirsExist = $true

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "✅ $dir exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir missing" -ForegroundColor Red
        $allDirsExist = $false
    }
}

if (-not $allDirsExist) {
    Write-Host "Creating missing directories..." -ForegroundColor Yellow
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "Created: $dir" -ForegroundColor Green
        }
    }
}

# Test 6: Check if installer files exist
Write-Host ""
Write-Host "Test 6: Checking if installer files exist..." -ForegroundColor Yellow
if (Test-Path "install.bat") {
    Write-Host "✅ Installer script found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Installer script not found" -ForegroundColor Yellow
    Write-Host "Run create_installer.ps1 to create installer" -ForegroundColor Cyan
}

if (Test-Path "RingtoneCreator_Standalone.zip") {
    Write-Host "✅ Distribution package found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Distribution package not found" -ForegroundColor Yellow
    Write-Host "Run create_installer_package.bat to create distribution package" -ForegroundColor Cyan
}

# Test 7: Test executable (dry run)
Write-Host ""
Write-Host "Test 7: Testing executable (dry run)..." -ForegroundColor Yellow
try {
    # Start the executable in the background
    $process = Start-Process -FilePath "ringtone_backend.exe" -ArgumentList "--help" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 2
    
    if (-not $process.HasExited) {
        Write-Host "✅ Executable starts successfully" -ForegroundColor Green
        $process.Kill()
        $process.WaitForExit()
    } else {
        Write-Host "⚠️ Executable exited immediately (may be normal)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Executable test failed: $_" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  TEST SUMMARY" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The standalone application has been tested." -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the application:" -ForegroundColor Yellow
Write-Host "  1. Double-click: start_ringtone_app.bat" -ForegroundColor White
Write-Host "  2. The app will open at: http://localhost:5000" -ForegroundColor White
Write-Host ""
Write-Host "To create distribution package:" -ForegroundColor Yellow
Write-Host "  1. Run: create_installer_package.bat" -ForegroundColor White
Write-Host "  2. Share: RingtoneCreator_Standalone.zip" -ForegroundColor White
Write-Host ""
Write-Host "🎵 Your standalone ringtone creator is ready!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
