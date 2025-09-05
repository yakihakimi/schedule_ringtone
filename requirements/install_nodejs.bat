@echo off
REM Rules applied
REM Node.js installation script for Windows
REM This script downloads and installs Node.js if it's not already installed

echo ========================================
echo Installing Node.js
echo ========================================
echo.

REM Check if Node.js is already installed
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Node.js is already installed:
    node --version
    echo.
    echo Checking npm...
    npm --version
    echo.
    echo Node.js installation is complete!
    goto :end
)

echo Node.js not found. Installing Node.js...
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

REM Try winget installation first (more reliable on modern Windows)
echo Attempting to install Node.js using winget...
echo This is the recommended method for Windows 10/11.
echo.

REM Check if winget is available
winget --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Winget is available. Installing Node.js...
    winget install OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
) else (
    echo Winget is not available on this system. Skipping winget installation...
    goto :skip_winget
)
if %errorlevel% equ 0 (
    echo.
    echo Winget installation completed. Refreshing environment variables...
    timeout /t 10 /nobreak >nul
    echo Calling refreshenv to update PATH...
    call refreshenv
    
    REM Refresh PATH manually as well
    for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set SYSTEM_PATH=%%B
    for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set USER_PATH=%%B
    set PATH=%SYSTEM_PATH%;%USER_PATH%
    
    REM Check if installation was successful
    node --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo Node.js installation completed via winget!
        echo ========================================
        echo.
        echo Node.js version:
        node --version
        echo.
        echo npm version:
        npm --version
        echo.
        echo Node.js is now ready to use!
        echo.
        goto :end
    ) else (
        echo Winget installation completed but Node.js not found in PATH.
        echo Trying to locate Node.js installation...
        
        REM Check common Node.js installation paths
        set NODEJS_PATHS=C:\Program Files\nodejs;C:\Program Files (x86)\nodejs;%APPDATA%\npm
        for %%P in (%NODEJS_PATHS%) do (
            if exist "%%P\node.exe" (
                echo Found Node.js at: %%P
                set "PATH=%%P;%PATH%"
            )
        )
        
        REM Try again
        node --version >nul 2>&1
        if %errorlevel% equ 0 (
            echo.
            echo ========================================
            echo Node.js installation completed via winget!
            echo ========================================
            echo.
            echo Node.js version:
            node --version
            echo.
            echo npm version:
            npm --version
            echo.
            echo Node.js is now ready to use!
            echo.
            goto :end
        )
    )
)

:skip_winget
echo.
echo Winget installation failed or not available. Trying MSI installer method...
echo.

REM Create temporary directory for download
set TEMP_DIR=%TEMP%\nodejs_install
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo Downloading Node.js installer...
echo.

REM Download Node.js LTS version for Windows x64
REM Using the official Node.js download URL
set NODEJS_URL=https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
set INSTALLER_PATH=%TEMP_DIR%\nodejs-installer.msi

echo Downloading from: %NODEJS_URL%
echo Saving to: %INSTALLER_PATH%
echo.

REM Try to download using PowerShell (more reliable than curl on Windows)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%NODEJS_URL%' -OutFile '%INSTALLER_PATH%' -UseBasicParsing}"

if not exist "%INSTALLER_PATH%" (
    echo ERROR: Failed to download Node.js installer!
    echo Please check your internet connection and try again.
    echo.
    echo Alternative: Please download Node.js manually from https://nodejs.org
    echo.
    pause
    exit /b 1
)

echo Download completed successfully!
echo.

REM Install Node.js with proper parameters
echo Installing Node.js...
echo This will show the installation wizard. Please follow the prompts.
echo.
echo IMPORTANT: You may need to approve the installation when prompted.
echo.
pause
echo Starting installation...
start /wait msiexec /i "%INSTALLER_PATH%" /passive /norestart /log "%TEMP_DIR%\nodejs_install.log"

REM Check if installation completed successfully
if %errorlevel% equ 0 (
    echo Installation completed successfully!
) else (
    echo Installation failed with error code: %errorlevel%
    echo.
    echo This could be due to:
    echo   - Insufficient permissions (try running as Administrator)
    echo   - Antivirus software blocking the installation
    echo   - Corrupted download
    echo   - User cancelled the installation
    echo.
    goto :installation_failed
)

REM Check if installation was successful by looking at the log
if exist "%TEMP_DIR%\nodejs_install.log" (
    echo Installation log created. Checking for errors...
    findstr /i "error" "%TEMP_DIR%\nodejs_install.log" >nul
    if %errorlevel% equ 0 (
        echo WARNING: Installation log contains errors. Check: %TEMP_DIR%\nodejs_install.log
        echo.
        echo Last few lines of the log:
        powershell -Command "Get-Content '%TEMP_DIR%\nodejs_install.log' | Select-Object -Last 10"
        echo.
    ) else (
        echo Installation log shows no errors.
    )
) else (
    echo WARNING: Installation log not found. Installation may have failed.
)

REM Clean up installer
del "%INSTALLER_PATH%" >nul 2>&1
del "%TEMP_DIR%\nodejs_install.log" >nul 2>&1
rmdir "%TEMP_DIR%" >nul 2>&1

REM Refresh environment variables
echo Refreshing environment variables...
echo Calling refreshenv to update PATH...
call refreshenv
REM Also try to manually refresh PATH
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set SYSTEM_PATH=%%B
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set USER_PATH=%%B
set PATH=%SYSTEM_PATH%;%USER_PATH%

REM Check if installation was successful
echo.
echo Verifying installation...
echo Trying to find Node.js in common installation paths...

REM Check common Node.js installation paths
set NODEJS_PATHS=C:\Program Files\nodejs;C:\Program Files (x86)\nodejs;%APPDATA%\npm
for %%P in (%NODEJS_PATHS%) do (
    if exist "%%P\node.exe" (
        echo Found Node.js at: %%P
        set "PATH=%%P;%PATH%"
    )
)

REM Try to run node command
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Node.js installation completed successfully!
    echo ========================================
    echo.
    echo Node.js version:
    node --version
    echo.
    echo npm version:
    npm --version
    echo.
    echo Node.js is now ready to use!
    echo.
) else (
    goto :installation_failed
)

:installation_failed
echo.
echo ========================================
echo Node.js installation failed!
echo ========================================
echo.
echo Please try the following:
echo 1. Restart your command prompt or PowerShell
echo 2. Check if Node.js was installed in Program Files
echo 3. Manually download and install from https://nodejs.org
echo 4. Try running this script as Administrator
echo.
echo If you just installed Node.js, you may need to restart your terminal.
echo.
exit /b 1

:end
echo.
pause
