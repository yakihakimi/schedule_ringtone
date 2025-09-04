# 🎵 Ringtone Creator App

A modern React application for creating custom ringtones from MP3 files with a Python Flask backend for persistent storage.

## ✨ Features

- **Audio Upload**: Drag & drop MP3 file upload with validation
- **Audio Editor**: Interactive audio player with play/pause, seek, and volume control
- **Ringtone Creation**: Create ringtones by selecting start and end times
- **Persistent Storage**: Save ringtones to the `ringtones` folder via backend API
- **Ringtone Management**: View, download, and delete saved ringtones
- **Responsive Design**: Works on both desktop and mobile devices

## 🚀 Quick Start

### Prerequisites

- **Frontend**: Node.js 16+ and npm
- **Backend**: Python 3.7+ and pip

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ringtone-app
   ```

2. **Install frontend dependencies**
   ```bash
   npm install
   ```

3. **Start the backend server**
   ```bash
   # Windows (Command Prompt)
   start_backend.bat
   
   # Windows (PowerShell)
   .\start_backend.ps1
   
   # Manual Python setup
   cd backend
   python -m venv venv
   venv\Scripts\activate  # Windows
   pip install -r requirements.txt
   python server.py
   ```

4. **Start the frontend application**
   ```bash
   npm start
   ```

5. **Open your browser**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

## 📁 Project Structure

```
ringtone-app/
├── src/                    # React frontend source code
│   ├── components/         # React components
│   │   ├── AudioPlayer.tsx    # Audio player with ringtone creation
│   │   ├── FileUpload.tsx     # File upload component
│   │   └── RingtoneList.tsx   # Ringtone management
│   ├── services/          # API services
│   │   └── ringtoneService.ts # Backend communication
│   └── types/             # TypeScript type definitions
├── backend/               # Python Flask backend
│   ├── server.py          # Main Flask application
│   └── requirements.txt   # Python dependencies
├── ringtones/             # Saved ringtones folder
├── original_sound/        # Original audio files folder
└── start_backend.bat      # Windows backend startup script
```

## 🔧 How It Works

### Frontend (React + TypeScript)
- **FileUpload**: Handles MP3 file uploads with drag & drop
- **AudioPlayer**: Provides audio playback controls and ringtone creation tools
- **RingtoneList**: Manages and displays created ringtones
- **ringtoneService**: Communicates with the backend API

### Backend (Python Flask)
- **File Storage**: Saves ringtones to the `ringtones` folder
- **API Endpoints**: RESTful API for ringtone management
- **File Validation**: Ensures only valid audio files are processed
- **CORS Support**: Allows frontend communication

### Ringtone Creation Process
1. Upload an MP3 file through the frontend
2. Use the audio player to select start and end times
3. Click "Create Ringtone" to generate the ringtone
4. The ringtone is automatically saved to the backend
5. The ringtone is downloaded to your local machine
6. The ringtone appears in the "Saved Ringtones" section

## 📡 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Server health check |
| `/api/ringtones` | GET | List all saved ringtones |
| `/api/ringtones` | POST | Save a new ringtone |
| `/api/ringtones/<filename>` | GET | Download a ringtone |
| `/api/ringtones/<filename>` | DELETE | Delete a ringtone |
| `/api/upload` | POST | Upload an audio file |

## 🎨 Customization

### Styling
- Modify `src/App.css` to customize the appearance
- The app uses CSS Grid and Flexbox for responsive layouts
- Color scheme can be adjusted in the CSS variables

### Backend Configuration
- Edit `backend/server.py` to modify server settings
- Change port numbers, folder paths, or add new endpoints
- Modify file validation rules in the upload handlers

## 🐛 Troubleshooting

### Common Issues

1. **Backend won't start**
   - Ensure Python 3.7+ is installed and in PATH
   - Check if port 5000 is available
   - Verify all dependencies are installed

2. **Frontend can't connect to backend**
   - Ensure the backend server is running on port 5000
   - Check browser console for CORS errors
   - Verify the API_BASE_URL in `ringtoneService.ts`

3. **File upload fails**
   - Check file size (max 50MB recommended)
   - Ensure file is a valid audio format (.mp3, .wav, .m4a, .ogg)
   - Verify the `original_sound` folder exists and is writable

4. **Ringtone creation fails**
   - Ensure start time is before end time
   - Ringtone can be any length (minimum 1 second)
   - Check browser console for Web Audio API errors

### Debug Mode
- Backend runs in debug mode by default
- Check terminal output for detailed error messages
- Frontend errors are logged to browser console

## 🔒 Security Features

- File type validation for uploads
- Secure file handling practices
- Input sanitization and validation
- CORS configuration for controlled access

## 📱 Browser Compatibility

- **Modern Browsers**: Chrome 60+, Firefox 55+, Safari 11+, Edge 79+
- **Required APIs**: Web Audio API, File API, Fetch API
- **Mobile**: Responsive design for iOS and Android

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review the browser console for errors
3. Check the backend terminal for server errors
4. Create an issue with detailed error information

---

**Note**: This application requires both the frontend and backend to be running simultaneously for full functionality. The backend handles file persistence while the frontend provides the user interface.
