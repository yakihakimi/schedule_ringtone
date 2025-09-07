# Ringtone Creator - Standalone Application

This is a standalone version of the Ringtone Creator application that runs without requiring Python, Node.js, or any other dependencies to be installed on the target system.

## 🚀 Quick Start

### For End Users:
1. **Download** the `RingtoneCreator_Standalone.zip` file
2. **Extract** the zip file to any location on your computer
3. **Run** `install.bat` to install the application
4. **Launch** the application using the desktop shortcut or start menu

### For Developers:
1. **Build** the standalone app: `.\build_complete.ps1`
2. **Test** the application: `.\start_ringtone_app.bat`
3. **Distribute** the `RingtoneCreator_Standalone.zip` file

## 📋 Features

- ✅ **Standalone Executable** - No dependencies required
- ✅ **Audio File Upload** - Support for MP3 and WAV files
- ✅ **Ringtone Creation** - Custom start/end time selection
- ✅ **Windows Task Scheduler** - Schedule ringtones to play at specific times
- ✅ **Dual Format Support** - Creates both WAV and MP3 versions
- ✅ **Modern Web Interface** - Clean, responsive design
- ✅ **Audio Processing** - Built-in FFmpeg for audio conversion
- ✅ **Easy Distribution** - Single zip file contains everything

## 🏗️ Architecture

The standalone application consists of:

### Backend (Python Flask)
- **Executable**: `ringtone_backend.exe` (PyInstaller bundle)
- **Features**: API endpoints, audio processing, task scheduling
- **Dependencies**: All Python packages bundled into the executable

### Frontend (React)
- **Location**: `frontend/` directory
- **Features**: Web interface, audio player, file management
- **Build**: Production-optimized static files

### Audio Processing
- **FFmpeg**: Bundled in `ffmpeg/` directory
- **Formats**: MP3, WAV support
- **Conversion**: Automatic format conversion

## 📁 File Structure

```
standalone_ringtone_app/
├── ringtone_backend.exe          # Main application executable
├── start_ringtone_app.bat        # Launcher script
├── install.bat                   # Installer script
├── README.md                     # User instructions
├── frontend/                     # Web interface files
│   ├── index.html
│   ├── static/
│   └── ...
├── ffmpeg/                       # Audio processing tools
│   └── bin/
│       ├── ffmpeg.exe
│       └── ffplay.exe
├── ringtones/                    # Created ringtones storage
│   ├── wav_ringtones/
│   └── mp3_ringtones/
├── original_sound/               # Uploaded audio files
└── installer/                    # Installation scripts
    ├── install.bat
    └── setup.bat
```

## 🛠️ Build Process

### Prerequisites
- Python 3.7+ with pip
- Node.js and npm
- PowerShell (Windows)

### Build Steps
1. **Run the complete build script**:
   ```powershell
   .\build_complete.ps1
   ```

2. **Individual build steps**:
   ```powershell
   # Build standalone application
   .\build_standalone.ps1
   
   # Install FFmpeg
   .\install_ffmpeg.ps1
   
   # Create installer
   .\create_installer.ps1
   
   # Create distribution package
   .\create_installer_package.bat
   ```

### Build Output
- `ringtone_backend.exe` - Main application
- `RingtoneCreator_Standalone.zip` - Distribution package
- `install.bat` - Installer script

## 🎯 Usage

### Starting the Application
1. **Double-click** `start_ringtone_app.bat`
2. **Wait** for the backend to start (console window will appear)
3. **Browser** will automatically open to `http://localhost:5000`

### Creating Ringtones
1. **Upload** an MP3 or WAV audio file
2. **Select** start and end times using the audio player
3. **Click** "Create Ringtone" to generate the ringtone
4. **View** your ringtones in the "Existing Ringtones" tab

### Scheduling Ringtones
1. **Go to** the "Schedule Ringtone" tab
2. **Select** a ringtone from your library
3. **Choose** the time and days to play
4. **Click** "Create Schedule" to set up the task

## 🔧 Technical Details

### Backend (Flask)
- **Port**: 5000 (configurable)
- **Host**: 127.0.0.1 (localhost only)
- **API**: RESTful endpoints for all operations
- **Logging**: Console and file logging

### Frontend (React)
- **Build**: Production build with optimizations
- **Routing**: Single-page application
- **Styling**: CSS with responsive design
- **Audio**: Web Audio API for playback

### Audio Processing
- **Library**: pydub (Python)
- **Codecs**: FFmpeg for format conversion
- **Formats**: MP3, WAV input/output
- **Quality**: 128kbps MP3 output

### Task Scheduling
- **Service**: Windows Task Scheduler
- **Integration**: COM interface via Python
- **Features**: Create, delete, enable, disable tasks

## 🐛 Troubleshooting

### Common Issues

**Application won't start:**
- Check if port 5000 is available
- Run as administrator if needed
- Check console output for error messages

**Audio conversion fails:**
- Ensure FFmpeg is properly installed
- Check file permissions
- Verify audio file format is supported

**Task scheduling doesn't work:**
- Run as administrator
- Check Windows Task Scheduler service
- Verify ringtone file paths are correct

**Frontend not loading:**
- Check if `frontend/` directory exists
- Verify `index.html` is present
- Check browser console for errors

### Log Files
- **Backend**: Console output and `ringtone_playback.log`
- **Frontend**: Browser developer console
- **System**: Windows Event Viewer

## 📦 Distribution

### Creating Distribution Package
1. **Run** `build_complete.ps1` to build everything
2. **Share** the `RingtoneCreator_Standalone.zip` file
3. **Recipients** extract and run `install.bat`

### Installation Process
1. **Extract** the zip file
2. **Run** `install.bat` as administrator
3. **Choose** installation directory
4. **Desktop** and start menu shortcuts are created
5. **Application** is ready to use

### Uninstallation
1. **Run** `uninstall.bat` from the installation directory
2. **Confirm** uninstallation
3. **All files** and shortcuts are removed

## 🔒 Security

- **Local Only**: Application runs on localhost only
- **No Network**: No external network connections
- **File Access**: Only accesses local audio files
- **Task Scheduler**: Uses Windows built-in scheduler

## 📝 System Requirements

### Minimum Requirements
- **OS**: Windows 10 or later
- **RAM**: 512MB available
- **Disk**: 100MB free space
- **Audio**: Sound card and speakers

### Recommended
- **OS**: Windows 11
- **RAM**: 2GB available
- **Disk**: 500MB free space
- **Audio**: High-quality sound card

## 🤝 Support

### Getting Help
1. **Check** the console output for error messages
2. **Review** the log files for detailed information
3. **Verify** all prerequisites are installed
4. **Test** with different audio files

### Reporting Issues
- Include console output
- Provide log file contents
- Describe steps to reproduce
- Specify system information

## 📄 License

This application is provided as-is for personal and educational use.

## 🎵 Enjoy Your Ringtones!

The standalone Ringtone Creator is now ready to use. Create custom ringtones, schedule them to play at specific times, and enjoy your personalized audio experience!
