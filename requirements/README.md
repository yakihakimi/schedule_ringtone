# Requirements Installation Scripts

This directory contains all the installation scripts for the Ringtone Creator project.

## 📁 Files Overview

### **Complete Installation Scripts**
- `install_all_requirements.bat` - Installs both Python and npm requirements (Windows)
- `install_all_requirements.ps1` - Installs both Python and npm requirements (PowerShell)

### **Individual Installation Scripts**
- `install_requirements.bat` - Installs Python requirements only (Windows)
- `install_requirements.ps1` - Installs Python requirements only (PowerShell)
- `install_npm_requirements.bat` - Installs npm requirements only (Windows)
- `install_npm_requirements.ps1` - Installs npm requirements only (PowerShell)

## 🚀 Usage

### **Option 1: Install Everything (Recommended)**
```bash
# Windows Command Prompt
requirements\install_all_requirements.bat

# PowerShell
.\requirements\install_all_requirements.ps1
```

### **Option 2: Install Separately**
```bash
# Install Python requirements only
requirements\install_requirements.bat

# Install npm requirements only
requirements\install_npm_requirements.bat
```

### **Option 3: Automatic Installation**
The start scripts (`start_app.bat`, `start_app.ps1`, `start_backend.bat`, `start_backend.ps1`) will automatically call these installation scripts if requirements are missing.

## 📦 What Gets Installed

### **Python Requirements** (from `backend/requirements.txt`)
- Flask 2.3.3 - Web framework
- Flask-CORS 4.0.0 - Cross-origin resource sharing
- Werkzeug 2.3.7 - WSGI toolkit
- pydub 0.25.1 - Audio processing
- pygame 2.6.0 - Audio playback
- requests 2.31.0 - HTTP requests
- python-dateutil 2.8.2 - Date/time handling

### **NPM Requirements** (from `package.json`)
- React 19.1.1 - Frontend framework
- TypeScript 4.9.5 - Type checking
- wavesurfer.js 7.10.1 - Audio visualization
- Testing libraries - Jest, React Testing Library
- And more...

## 🔧 Features

- **Automatic Detection** - Checks if requirements are already installed
- **Verbose Output** - Shows detailed installation progress
- **Error Handling** - Clear error messages and troubleshooting tips
- **Cross-Platform** - Works on Windows with both CMD and PowerShell
- **Smart Retry** - Start scripts automatically retry after installing requirements

## 🛠️ Troubleshooting

### **Common Issues**

1. **Python not found**
   - Install Python 3.13+ from https://python.org
   - Make sure Python is added to PATH

2. **Node.js not found**
   - Install Node.js from https://nodejs.org
   - Make sure npm is available

3. **Permission errors**
   - Run as Administrator if needed
   - Check antivirus software blocking installations

4. **Network issues**
   - Check internet connection
   - Try using a different npm registry: `npm config set registry https://registry.npmjs.org/`

### **Manual Installation**
If scripts fail, you can install manually:
```bash
# Python requirements
pip install -r backend/requirements.txt --verbose

# NPM requirements
npm install --verbose
```

## 📝 Notes

- All scripts follow the project rules (verbose output, error handling)
- Scripts are designed to work from the requirements directory
- Installation scripts automatically navigate to the correct directories
- Start scripts will automatically install missing requirements
