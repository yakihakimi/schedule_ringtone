@echo off
REM Rules applied
REM FFmpeg installation script for Windows
REM This script downloads and installs FFmpeg for MP3 conversion

echo ========================================
echo Installing FFmpeg
echo ========================================
echo.

REM Check if FFmpeg is already installed
ffmpeg -version >nul 2>&1
if %errorlevel% equ 0 (
    echo FFmpeg is already installed:
    ffmpeg -version 2>&1 | findstr "ffmpeg version"
    echo.
    echo FFmpeg installation is complete!
    goto :end
)

echo FFmpeg not found. Installing FFmpeg...
echo.

REM Check if we have internet connectivity
echo Checking internet connectivity...
ping -n 1 google.com >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No internet connection detected!
    echo Please check your internet connection and try again.
    echo.
    pause
    exit /b 1
)

echo Internet connection verified.
echo.

REM Create temporary directory for download
set TEMP_DIR=%TEMP%\ffmpeg_install
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Downloading FFmpeg...
echo.

REM Download FFmpeg from official source
REM Using the official FFmpeg build from gyan.dev
set FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
set ZIP_PATH=%TEMP_DIR%\ffmpeg.zip
set EXTRACT_PATH=%TEMP_DIR%\ffmpeg

echo Downloading from: %FFMPEG_URL%
echo Saving to: %ZIP_PATH%
echo.

REM Try to download using PowerShell (more reliable than curl on Windows)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%FFMPEG_URL%' -OutFile '%ZIP_PATH%' -UseBasicParsing}"

if not exist "%ZIP_PATH%" (
    echo ERROR: Failed to download FFmpeg!
    echo Please check your internet connection and try again.
    echo.
    echo Alternative: Please download FFmpeg manually from https://ffmpeg.org
    echo.
    pause
    exit /b 1
)

echo Download completed successfully!
echo.

echo Extracting FFmpeg...
echo.

REM Extract the zip file
powershell -Command "& {Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%TEMP_DIR%' -Force}"

REM Find the extracted folder (it has a version number in the name)
for /d %%i in ("%TEMP_DIR%\ffmpeg-*") do set FFMPEG_FOLDER=%%i

if not exist "%FFMPEG_FOLDER%" (
    echo ERROR: Failed to extract FFmpeg!
    echo.
    pause
    exit /b 1
)

echo FFmpeg extracted to: %FFMPEG_FOLDER%
echo.

REM Create FFmpeg directory in Program Files
set INSTALL_DIR=C:\ffmpeg
echo Installing FFmpeg to: %INSTALL_DIR%
echo.

REM Create the installation directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy FFmpeg files
xcopy "%FFMPEG_FOLDER%\bin\*" "%INSTALL_DIR%\bin\" /E /I /Y >nul
xcopy "%FFMPEG_FOLDER%\doc\*" "%INSTALL_DIR%\doc\" /E /I /Y >nul
xcopy "%FFMPEG_FOLDER%\presets\*" "%INSTALL_DIR%\presets\" /E /I /Y >nul

REM Add FFmpeg to PATH (current session)
set PATH=%INSTALL_DIR%\bin;%PATH%

REM Try to add FFmpeg to system PATH permanently
echo Adding FFmpeg to system PATH...
powershell -Command "& {[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';%INSTALL_DIR%\bin', 'Machine')}" >nul 2>&1

REM Clean up temporary files
echo Cleaning up temporary files...
rmdir /s /q "%TEMP_DIR%" >nul 2>&1

REM Check if installation was successful
echo.
echo Verifying installation...
ffmpeg -version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo FFmpeg installation completed successfully!
    echo ========================================
    echo.
    echo FFmpeg version:
    ffmpeg -version 2>&1 | findstr "ffmpeg version"
    echo.
    echo FFmpeg is now ready for MP3 conversion!
    echo Installation path: %INSTALL_DIR%\bin
    echo.
    echo Note: You may need to restart your terminal for PATH changes to take effect.
    echo.
) else (
    echo.
    echo ========================================
    echo FFmpeg installation may have failed!
    echo ========================================
    echo.
    echo Please try the following:
    echo 1. Restart your command prompt or PowerShell
    echo 2. Check if FFmpeg was installed in C:\ffmpeg\bin
    echo 3. Manually download and install from https://ffmpeg.org
    echo.
    echo If you just installed FFmpeg, you may need to restart your terminal.
    echo.
)

:end
echo.
pause
