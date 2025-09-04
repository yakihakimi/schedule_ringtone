# 🎵 Ringtone Creator App

A React-based web application for creating custom ringtones from audio files with precise start and end time selection.

## 🚀 Quick Start

### Windows Users
Simply double-click **`start_app.bat`** or **`start_app.ps1`** in the main project folder!

This will automatically:
1. ✅ Start the Python Flask backend server (in a new window)
2. ✅ Start the React frontend development server
3. ✅ Open your browser to http://localhost:3000

### What Happens When You Click Start App:
- **Backend Server**: Starts automatically in a new command prompt window at http://localhost:5000
- **Frontend App**: Opens in your browser at http://localhost:3000
- **Both servers run simultaneously** - you can close the frontend without affecting the backend

## 📁 Project Structure

```
‏‏ringbreak-react/
├── start_app.bat          ← 🎯 CLICK THIS TO START EVERYTHING!
├── start_app.ps1          ← 🎯 OR THIS (PowerShell version)
├── start_backend.bat      ← Backend startup (called automatically)
├── start_backend.ps1      ← Backend startup (called automatically)
├── ringtones/             ← 🎵 Your created ringtones are saved here
├── original_sound/        ← 📁 Original audio files
└── ringtone-app/          ← React frontend application
    ├── src/
    ├── backend/           ← Python Flask server
    └── package.json
```

## 🔧 Manual Setup (if needed)

### Prerequisites
- **Python 3.7+** with pip
- **Node.js 14+** with npm
- **Git** (for cloning)

### Backend Setup
```bash
cd ringtone-app/backend
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
python server.py
```

### Frontend Setup
```bash
cd ringtone-app
npm install
npm start
```

## 🌟 Features

- **🎵 Audio Upload**: Drag & drop MP3, WAV, M4A, OGG files
- **⏱️ Precise Timing**: Set exact start and end times for ringtones
- **💾 Persistent Storage**: Ringtones automatically saved to `ringtones/` folder
- **🔄 MP3 Conversion**: Automatic WAV to MP3 conversion
- **📱 Responsive Design**: Works on desktop and mobile
- **🎨 Modern UI**: Clean, intuitive interface

## 📡 API Endpoints

The backend provides these endpoints:

- `GET /health` - Server health check
- `GET /api/ringtones` - List all saved ringtones
- `POST /api/ringtones` - Save a new ringtone
- `GET /api/ringtones/<filename>` - Download a ringtone
- `DELETE /api/ringtones/<filename>` - Delete a ringtone
- `POST /api/upload` - Upload original audio file

## 🎯 How It Works

1. **Upload Audio**: Drag & drop an audio file
2. **Set Times**: Use the pin buttons or input fields to set start/end times
3. **Create Ringtone**: Click "Create Ringtone" to extract the segment
4. **Auto-Save**: Ringtone is automatically saved to the `ringtones/` folder
5. **Download**: Get your ringtone as WAV or MP3 format
6. **Persistent**: Ringtones are loaded automatically when you restart the app

## 🛠️ Troubleshooting

### Backend Won't Start?
- Check if Python 3.7+ is installed: `python --version`
- Install dependencies: `pip install -r ringtone-app/backend/requirements.txt`
- Check if port 5000 is available

### Frontend Won't Start?
- Check if Node.js is installed: `node --version`
- Install dependencies: `cd ringtone-app && npm install`
- Check if port 3000 is available

### Ringtones Not Saving?
- Ensure the `ringtones/` folder exists in the main project directory
- Check backend server logs for path information
- Verify file permissions on the `ringtones/` folder

## 📝 Development

### Backend Development
- Server runs on http://localhost:5000
- Logs show exact file paths being used
- Supports hot reloading in debug mode

### Frontend Development
- React app runs on http://localhost:3000
- TypeScript compilation with hot reloading
- Modern React hooks and functional components

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

---

**🎉 Happy Ringtone Creating!** 🎵
