# Rules applied
Write-Host "Creating Installer for Standalone Ringtone Creator..." -ForegroundColor Green
Write-Host ""

# Create installer directory
$installerDir = "installer"
if (-not (Test-Path $installerDir)) {
    New-Item -ItemType Directory -Path $installerDir -Force | Out-Null
    Write-Host "Created installer directory: $installerDir" -ForegroundColor Green
}

# Create the main installer script
$installerScript = @"
# Rules applied
@echo off
title Ringtone Creator - Installer
echo.
echo ========================================
echo   Ringtone Creator - Installer
echo ========================================
echo.
echo This installer will set up the Ringtone Creator application
echo on your system.
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo WARNING: Not running as administrator.
    echo Some features may not work properly.
    echo.
)

REM Get installation directory
set /p INSTALL_DIR="Enter installation directory (default: C:\Program Files\RingtoneCreator): "
if "%INSTALL_DIR%"=="" set INSTALL_DIR=C:\Program Files\RingtoneCreator

echo.
echo Installing to: %INSTALL_DIR%
echo.

REM Create installation directory
if not exist "%INSTALL_DIR%" (
    echo Creating installation directory...
    mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo ERROR: Failed to create installation directory!
        echo Please run as administrator or choose a different location.
        echo.
        pause
        exit /b 1
    )
)

REM Copy application files
echo Copying application files...
xcopy /E /I /Y "%~dp0*" "%INSTALL_DIR%"
if errorlevel 1 (
    echo ERROR: Failed to copy application files!
    echo.
    pause
    exit /b 1
)

REM Create desktop shortcut
echo Creating desktop shortcut...
set DESKTOP=%USERPROFILE%\Desktop
echo [InternetShortcut] > "%DESKTOP%\Ringtone Creator.url"
echo URL=file:///%INSTALL_DIR%/start_ringtone_app.bat >> "%DESKTOP%\Ringtone Creator.url"
echo IconFile=%INSTALL_DIR%/ringtone_backend.exe >> "%DESKTOP%\Ringtone Creator.url"
echo IconIndex=0 >> "%DESKTOP%\Ringtone Creator.url"

REM Create start menu shortcut
echo Creating start menu shortcut...
set START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs
if not exist "%START_MENU%\Ringtone Creator" mkdir "%START_MENU%\Ringtone Creator"
echo [InternetShortcut] > "%START_MENU%\Ringtone Creator\Ringtone Creator.url"
echo URL=file:///%INSTALL_DIR%/start_ringtone_app.bat >> "%START_MENU%\Ringtone Creator\Ringtone Creator.url"
echo IconFile=%INSTALL_DIR%/ringtone_backend.exe >> "%START_MENU%\Ringtone Creator\Ringtone Creator.url"
echo IconIndex=0 >> "%START_MENU%\Ringtone Creator\Ringtone Creator.url"

REM Create uninstaller
echo Creating uninstaller...
echo @echo off > "%INSTALL_DIR%\uninstall.bat"
echo title Ringtone Creator - Uninstaller >> "%INSTALL_DIR%\uninstall.bat"
echo echo. >> "%INSTALL_DIR%\uninstall.bat"
echo echo Uninstalling Ringtone Creator... >> "%INSTALL_DIR%\uninstall.bat"
echo echo. >> "%INSTALL_DIR%\uninstall.bat"
echo set /p CONFIRM="Are you sure you want to uninstall? (Y/N): " >> "%INSTALL_DIR%\uninstall.bat"
echo if /i "%%CONFIRM%%"=="Y" ( >> "%INSTALL_DIR%\uninstall.bat"
echo     echo Removing application files... >> "%INSTALL_DIR%\uninstall.bat"
echo     rmdir /S /Q "%INSTALL_DIR%" >> "%INSTALL_DIR%\uninstall.bat"
echo     echo Removing shortcuts... >> "%INSTALL_DIR%\uninstall.bat"
echo     del "%DESKTOP%\Ringtone Creator.url" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo     rmdir /S /Q "%START_MENU%\Ringtone Creator" 2^>nul >> "%INSTALL_DIR%\uninstall.bat"
echo     echo Uninstallation complete! >> "%INSTALL_DIR%\uninstall.bat"
echo ^) else ( >> "%INSTALL_DIR%\uninstall.bat"
echo     echo Uninstallation cancelled. >> "%INSTALL_DIR%\uninstall.bat"
echo ^) >> "%INSTALL_DIR%\uninstall.bat"
echo pause >> "%INSTALL_DIR%\uninstall.bat"

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Ringtone Creator has been installed to:
echo %INSTALL_DIR%
echo.
echo Desktop shortcut created: Ringtone Creator
echo Start menu shortcut created: Ringtone Creator
echo.
echo To start the application:
echo 1. Double-click the desktop shortcut, or
echo 2. Use the start menu shortcut, or
echo 3. Run: %INSTALL_DIR%\start_ringtone_app.bat
echo.
echo To uninstall:
echo Run: %INSTALL_DIR%\uninstall.bat
echo.
echo Thank you for installing Ringtone Creator!
echo.
pause
"@

$installerScript | Out-File -FilePath "$installerDir\install.bat" -Encoding ASCII
Write-Host "Installer script created: $installerDir\install.bat" -ForegroundColor Green

# Create a simple setup script for the installer
$setupScript = @"
# Rules applied
@echo off
title Ringtone Creator - Setup
echo.
echo ========================================
echo   Ringtone Creator - Setup
echo ========================================
echo.
echo This will prepare the Ringtone Creator installer package.
echo.

REM Check if the application files exist
if not exist "ringtone_backend.exe" (
    echo ERROR: ringtone_backend.exe not found!
    echo Please run build_standalone.ps1 first to build the application.
    echo.
    pause
    exit /b 1
)

if not exist "frontend" (
    echo ERROR: frontend folder not found!
    echo Please run build_standalone.ps1 first to build the application.
    echo.
    pause
    exit /b 1
)

echo Application files found. Creating installer package...
echo.

REM Copy installer to the main directory
copy "installer\install.bat" "install.bat"
echo Installer copied to main directory.

REM Create a zip file for distribution
echo Creating distribution package...
powershell -Command "Compress-Archive -Path 'ringtone_backend.exe', 'start_ringtone_app.bat', 'frontend', 'install.bat', 'README.md' -DestinationPath 'RingtoneCreator_Standalone.zip' -Force"
echo Distribution package created: RingtoneCreator_Standalone.zip

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Files ready for distribution:
echo   - RingtoneCreator_Standalone.zip (Complete package)
echo   - install.bat (Installer script)
echo.
echo To distribute:
echo 1. Share the RingtoneCreator_Standalone.zip file
echo 2. Recipients should extract and run install.bat
echo.
pause
"@

$setupScript | Out-File -FilePath "$installerDir\setup.bat" -Encoding ASCII
Write-Host "Setup script created: $installerDir\setup.bat" -ForegroundColor Green

# Create a batch file to run the setup
$runSetupScript = @"
# Rules applied
@echo off
title Ringtone Creator - Run Setup
echo.
echo ========================================
echo   Ringtone Creator - Run Setup
echo ========================================
echo.
echo This will create the installer package for distribution.
echo.

REM Run the setup script
call "installer\setup.bat"

echo.
echo Setup process completed!
echo.
pause
"@

$runSetupScript | Out-File -FilePath "create_installer_package.bat" -Encoding ASCII
Write-Host "Setup runner created: create_installer_package.bat" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Installer Creation Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  - installer\install.bat (Main installer script)" -ForegroundColor White
Write-Host "  - installer\setup.bat (Setup script)" -ForegroundColor White
Write-Host "  - create_installer_package.bat (Run this to create distribution package)" -ForegroundColor White
Write-Host ""
Write-Host "To create the distribution package:" -ForegroundColor Yellow
Write-Host "  1. First run: build_standalone.ps1" -ForegroundColor White
Write-Host "  2. Then run: create_installer_package.bat" -ForegroundColor White
Write-Host ""
Write-Host "This will create RingtoneCreator_Standalone.zip for distribution!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
