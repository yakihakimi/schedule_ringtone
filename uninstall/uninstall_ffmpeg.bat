@echo off
REM Rules applied
REM Uninstall FFmpeg from Windows system
REM This script removes FFmpeg installation and cleans up related files

echo ========================================
echo FFmpeg Uninstaller
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo WARNING: This script should be run as administrator for complete removal
    echo Some files may not be removed without admin privileges
    echo.
)

echo Starting FFmpeg uninstallation...
echo.

REM Stop any running FFmpeg processes
echo Stopping FFmpeg processes...
taskkill /f /im ffmpeg.exe >nul 2>&1
taskkill /f /im ffplay.exe >nul 2>&1
taskkill /f /im ffprobe.exe >nul 2>&1

echo Checking for FFmpeg installations...

REM Check for portable FFmpeg in project directory
if exist "ffmpeg" (
    echo Found portable FFmpeg in project directory
    echo Removing portable FFmpeg from project directory...
    rmdir /s /q "ffmpeg" >nul 2>&1
    if exist "ffmpeg" (
        echo WARNING: Could not completely remove portable FFmpeg directory
        echo You may need to manually delete: ffmpeg
    ) else (
        echo Successfully removed portable FFmpeg directory
    )
)

REM Check for system-wide FFmpeg installation
if exist "C:\ffmpeg" (
    echo Found system FFmpeg installation
    echo Removing system FFmpeg installation...
    rmdir /s /q "C:\ffmpeg" >nul 2>&1
    if exist "C:\ffmpeg" (
        echo WARNING: Could not completely remove system FFmpeg directory
        echo You may need to manually delete: C:\ffmpeg
    ) else (
        echo Successfully removed system FFmpeg directory
    )
)

REM Check for FFmpeg in Program Files
if exist "C:\Program Files\ffmpeg" (
    echo Found FFmpeg in Program Files
    echo Removing FFmpeg from Program Files...
    rmdir /s /q "C:\Program Files\ffmpeg" >nul 2>&1
    if exist "C:\Program Files\ffmpeg" (
        echo WARNING: Could not completely remove FFmpeg from Program Files
        echo You may need to manually delete: C:\Program Files\ffmpeg
    ) else (
        echo Successfully removed FFmpeg from Program Files
    )
)

REM Check for FFmpeg in Program Files (x86)
if exist "C:\Program Files (x86)\ffmpeg" (
    echo Found FFmpeg in Program Files (x86)
    echo Removing FFmpeg from Program Files (x86)...
    rmdir /s /q "C:\Program Files (x86)\ffmpeg" >nul 2>&1
    if exist "C:\Program Files (x86)\ffmpeg" (
        echo WARNING: Could not completely remove FFmpeg from Program Files (x86)
        echo You may need to manually delete: C:\Program Files (x86)\ffmpeg
    ) else (
        echo Successfully removed FFmpeg from Program Files (x86)
    )
)

REM Check for FFmpeg in user directory
if exist "%USERPROFILE%\ffmpeg" (
    echo Found FFmpeg in user directory
    echo Removing FFmpeg from user directory...
    rmdir /s /q "%USERPROFILE%\ffmpeg" >nul 2>&1
    if exist "%USERPROFILE%\ffmpeg" (
        echo WARNING: Could not completely remove FFmpeg from user directory
        echo You may need to manually delete: %USERPROFILE%\ffmpeg
    ) else (
        echo Successfully removed FFmpeg from user directory
    )
)

REM Remove FFmpeg from Windows registry
echo Cleaning Windows registry...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\FFmpeg" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\FFmpeg" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\FFmpeg" /f >nul 2>&1

REM Clean up temporary files
echo Cleaning temporary files...
if exist "%TEMP%\ffmpeg*" (
    del /q "%TEMP%\ffmpeg*" >nul 2>&1
    echo Removed FFmpeg temporary files
)

REM Clean up any remaining FFmpeg configuration files
echo Cleaning configuration files...
if exist "%USERPROFILE%\.ffmpeg" (
    rmdir /s /q "%USERPROFILE%\.ffmpeg" >nul 2>&1
    echo Removed FFmpeg configuration directory
)

echo.
echo ========================================
echo FFmpeg uninstallation completed!
echo ========================================
echo.
echo IMPORTANT: Please restart your computer or log out and back in
echo to ensure all environment variables are updated.
echo.
echo You may also want to manually check and remove:
echo - Any remaining FFmpeg folders in Program Files
echo - FFmpeg entries in your system PATH
echo - Any FFmpeg shortcuts on desktop or start menu
echo - FFmpeg configuration files in your user directory
echo.
echo NOTE: This script does not modify the system PATH automatically.
echo You may need to manually remove FFmpeg entries from your PATH
echo environment variable if they were added during installation.
echo.
pause