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

### **Runtime Installation Scripts**
- `install_python.bat` - Installs Python 3.13+ if not found (Windows)
- `install_python.ps1` - Installs Python 3.13+ if not found (PowerShell)
- `install_nodejs.bat` - Installs Node.js LTS if not found (Windows)
- `install_nodejs.ps1` - Installs Node.js LTS if not found (PowerShell)
- `install_ffmpeg.bat` - Installs FFmpeg for MP3 conversion (Windows)
- `install_ffmpeg.ps1` - Installs FFmpeg for MP3 conversion (PowerShell)

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
# Install Python requirements only (includes Python installation if needed)
requirements\install_requirements.bat

# Install npm requirements only (includes Node.js installation if needed)
requirements\install_npm_requirements.bat

# Install just Python runtime
requirements\install_python.bat

# Install just Node.js runtime
requirements\install_nodejs.bat

# Install just FFmpeg for MP3 conversion
requirements\install_ffmpeg.bat
```

### **Option 3: Automatic Installation**
The start scripts (`start_app.bat`, `start_app.ps1`, `start_backend.bat`, `start_backend.ps1`) will automatically call these installation scripts if requirements are missing.

## 📦 What Gets Installed

### **Python Requirements** (from `backend/requirements.txt`)
- Flask 2.3.3 - Web framework
- Flask-CORS 4.0.0 - Cross-origin resource sharing
- Werkzeug 2.3.7 - WSGI toolkit
- pydub 0.25.1 - Audio processing (requires FFmpeg for MP3 conversion)
- pygame 2.6.0 - Audio playback
- requests 2.31.0 - HTTP requests
- python-dateutil 2.8.2 - Date/time handling

### **System Requirements**
- Python 3.13.1 - Python runtime (auto-installed if missing)
- Node.js LTS v20.11.0 - Node.js runtime (auto-installed if missing)
- FFmpeg - Audio conversion tool (auto-installed if missing)

### **NPM Requirements** (from `package.json`)
- React 19.1.1 - Frontend framework
- TypeScript 4.9.5 - Type checking
- wavesurfer.js 7.10.1 - Audio visualization
- Testing libraries - Jest, React Testing Library
- And more...

## 🔧 Features

- **Automatic Detection** - Checks if requirements are already installed
- **Runtime Installation** - Automatically installs Python, Node.js, and FFmpeg if missing
- **Verbose Output** - Shows detailed installation progress
- **Error Handling** - Clear error messages and troubleshooting tips
- **Cross-Platform** - Works on Windows with both CMD and PowerShell
- **Smart Retry** - Start scripts automatically retry after installing requirements
- **Internet Connectivity** - Checks for internet connection before downloading
- **Clean Installation** - Downloads and installs official versions from official sources

## 🛠️ Troubleshooting

### **Common Issues**

1. **Python not found**
   - Scripts will automatically install Python 3.13.1
   - Manual installation: https://python.org
   - Make sure Python is added to PATH

2. **Node.js not found**
   - Scripts will automatically install Node.js LTS (v20.11.0)
   - Manual installation: https://nodejs.org
   - Make sure npm is available

3. **FFmpeg not found**
   - Scripts will automatically install FFmpeg for MP3 conversion
   - Manual installation: https://ffmpeg.org
   - Required for pydub MP3 conversion functionality

4. **Permission errors**
   - Run as Administrator if needed
   - Check antivirus software blocking installations

5. **Network issues**
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
