@echo off
REM Rules applied
REM Uninstall Node.js and npm from Windows system
REM This script removes Node.js installation and cleans up related files

echo ========================================
echo Node.js Uninstaller
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

echo Starting Node.js uninstallation...
echo.

REM Stop any running Node.js processes
echo Stopping Node.js processes...
taskkill /f /im node.exe >nul 2>&1
taskkill /f /im npm.exe >nul 2>&1

REM Find Node.js installation directory
set "NODE_PATH="
if exist "C:\Program Files\nodejs\" (
    set "NODE_PATH=C:\Program Files\nodejs\"
    echo Found Node.js in: %NODE_PATH%
) else if exist "C:\Program Files (x86)\nodejs\" (
    set "NODE_PATH=C:\Program Files (x86)\nodejs\"
    echo Found Node.js in: %NODE_PATH%
) else (
    echo Node.js installation not found in standard locations
    echo Please check if Node.js is installed
    pause
    exit /b 1
)

REM Remove Node.js from PATH environment variable
echo Removing Node.js from PATH...
setx PATH "%PATH:C:\Program Files\nodejs\;=%" >nul 2>&1
setx PATH "%PATH:C:\Program Files (x86)\nodejs\;=%" >nul 2>&1

REM Remove npm cache
echo Cleaning npm cache...
if exist "%APPDATA%\npm-cache\" (
    rmdir /s /q "%APPDATA%\npm-cache\" >nul 2>&1
    echo Removed npm cache directory
)

REM Remove npm global packages
echo Removing npm global packages...
if exist "%APPDATA%\npm\" (
    rmdir /s /q "%APPDATA%\npm\" >nul 2>&1
    echo Removed npm global packages directory
)

REM Remove Node.js installation directory
echo Removing Node.js installation directory...
if exist "%NODE_PATH%" (
    rmdir /s /q "%NODE_PATH%" >nul 2>&1
    if exist "%NODE_PATH%" (
        echo WARNING: Could not completely remove Node.js directory
        echo You may need to manually delete: %NODE_PATH%
    ) else (
        echo Successfully removed Node.js installation directory
    )
)

REM Remove Node.js from Windows registry
echo Cleaning Windows registry...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Node.js" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\Node.js" /f >nul 2>&1
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Node.js" /f >nul 2>&1

REM Remove npm from registry
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\npm" /f >nul 2>&1
reg delete "HKEY_CURRENT_USER\SOFTWARE\npm" /f >nul 2>&1

REM Clean up user profile
echo Cleaning user profile...
if exist "%USERPROFILE%\.npm\" (
    rmdir /s /q "%USERPROFILE%\.npm\" >nul 2>&1
    echo Removed user npm directory
)

if exist "%USERPROFILE%\.node-gyp\" (
    rmdir /s /q "%USERPROFILE%\.node-gyp\" >nul 2>&1
    echo Removed node-gyp directory
)

REM Remove from system PATH (requires admin)
echo Updating system PATH...
for /f "tokens=2*" %%A in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do (
    set "SYSTEM_PATH=%%B"
)

set "NEW_PATH=%SYSTEM_PATH%"
set "NEW_PATH=%NEW_PATH:C:\Program Files\nodejs\;=%"
set "NEW_PATH=%NEW_PATH:C:\Program Files (x86)\nodejs\;=%"

if not "%NEW_PATH%"=="%SYSTEM_PATH%" (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH /t REG_EXPAND_SZ /d "%NEW_PATH%" /f >nul 2>&1
    echo Updated system PATH
)

echo.
echo ========================================
echo Node.js uninstallation completed!
echo ========================================
echo.
echo IMPORTANT: Please restart your computer or log out and back in
echo to ensure all environment variables are updated.
echo.
echo You may also want to manually check and remove:
echo - Any remaining Node.js folders in Program Files
echo - Node.js entries in your system PATH
echo - Any Node.js shortcuts on desktop or start menu
echo.
pause
