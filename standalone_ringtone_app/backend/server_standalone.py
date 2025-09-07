# Rules applied
from flask import Flask, request, jsonify, send_file, send_from_directory
from flask_cors import CORS
import os
import uuid
from datetime import datetime
import logging
import json
import sys
import threading
import webbrowser
import time

# Configure ffmpeg path for pydub
def find_ffmpeg_path():
    """Find FFmpeg installation path dynamically"""
    import shutil
    
    # Get the directory where the executable is located
    if getattr(sys, 'frozen', False):
        # Running as PyInstaller bundle
        base_path = sys._MEIPASS
    else:
        # Running as script
        base_path = os.path.dirname(os.path.abspath(__file__))
    
    # First, check if ffmpeg is already in PATH
    ffmpeg_exe = shutil.which("ffmpeg")
    if ffmpeg_exe:
        ffmpeg_dir = os.path.dirname(ffmpeg_exe)
        logging.info(f"FFmpeg found in PATH: {ffmpeg_dir}")
        return ffmpeg_dir
    
    # Check in the standalone app's ffmpeg folder
    standalone_ffmpeg = os.path.join(os.path.dirname(base_path), "ffmpeg", "bin")
    if os.path.exists(standalone_ffmpeg):
        ffmpeg_exe = os.path.join(standalone_ffmpeg, "ffmpeg.exe")
        if os.path.exists(ffmpeg_exe):
            logging.info(f"FFmpeg found in standalone app: {standalone_ffmpeg}")
            return standalone_ffmpeg
    
    # Common FFmpeg installation paths on Windows
    possible_paths = [
        # WinGet installation path (dynamic user)
        os.path.expanduser(r"~\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.0-full_build\bin"),
        # Chocolatey installation
        r"C:\ProgramData\chocolatey\bin",
        # Manual installation in Program Files
        r"C:\Program Files\ffmpeg\bin",
        r"C:\Program Files (x86)\ffmpeg\bin",
        # Manual installation in user directory
        os.path.expanduser(r"~\ffmpeg\bin"),
        # Working directory (for portable installation)
        os.path.join(base_path, "ffmpeg", "bin"),
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            ffmpeg_exe = os.path.join(path, "ffmpeg.exe")
            if os.path.exists(ffmpeg_exe):
                logging.info(f"FFmpeg found at: {path}")
                return path
    
    logging.warning("FFmpeg not found in any common installation paths")
    return None

# Find and configure FFmpeg path
ffmpeg_path = find_ffmpeg_path()
if ffmpeg_path:
    os.environ["PATH"] = ffmpeg_path + os.pathsep + os.environ.get("PATH", "")
    logging.info(f"Added ffmpeg to PATH: {ffmpeg_path}")
else:
    logging.warning("FFmpeg not found - MP3 conversion may not work")

# Import the Windows Task Scheduler service
try:
    from taskSchedulerService import task_scheduler_service
    TASK_SCHEDULER_AVAILABLE = True
except ImportError as e:
    TASK_SCHEDULER_AVAILABLE = False
    print(f"⚠️ Windows Task Scheduler service not available: {e}")

try:
    from pydub import AudioSegment
    PYDUB_AVAILABLE = True
    
    # Test if pydub can actually convert audio (not just import)
    try:
        # Create a simple test audio and try to export it
        test_audio = AudioSegment.silent(duration=100)
        test_path = os.path.join(os.path.dirname(__file__), 'test_mp3_conversion.mp3')
        test_audio.export(test_path, format="mp3")
        
        # Check if file was created and has content
        if os.path.exists(test_path) and os.path.getsize(test_path) > 0:
            os.remove(test_path)  # Clean up test file
            PYDUB_FULLY_WORKING = True
            logging.info("pydub is available and audio conversion is working with ffmpeg")
        else:
            PYDUB_FULLY_WORKING = False
            logging.warning("pydub is available but audio conversion is not working (missing codecs)")
            
    except Exception as e:
        PYDUB_FULLY_WORKING = False
        logging.warning(f"pydub is available but audio conversion test failed: {e}")
        
except ImportError:
    PYDUB_AVAILABLE = False
    PYDUB_FULLY_WORKING = False
    logging.warning("pydub not available - MP3 conversion disabled")

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for React frontend

# Get the base directory for the standalone app
if getattr(sys, 'frozen', False):
    # Running as PyInstaller bundle
    BASE_DIR = os.path.dirname(sys.executable)
else:
    # Running as script
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Configuration - use relative paths from the standalone app
RINGTONES_FOLDER = os.path.join(BASE_DIR, 'ringtones')
WAV_RINGTONES_FOLDER = os.path.join(RINGTONES_FOLDER, 'wav_ringtones')
MP3_RINGTONES_FOLDER = os.path.join(RINGTONES_FOLDER, 'mp3_ringtones')
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'original_sound')
FRONTEND_FOLDER = os.path.join(BASE_DIR, 'frontend')

# Ensure directories exist
os.makedirs(RINGTONES_FOLDER, exist_ok=True)
os.makedirs(WAV_RINGTONES_FOLDER, exist_ok=True)
os.makedirs(MP3_RINGTONES_FOLDER, exist_ok=True)
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(FRONTEND_FOLDER, exist_ok=True)

# Log the actual paths being used
logger.info(f"BASE_DIR: {BASE_DIR}")
logger.info(f"RINGTONES_FOLDER: {os.path.abspath(RINGTONES_FOLDER)}")
logger.info(f"WAV_RINGTONES_FOLDER: {os.path.abspath(WAV_RINGTONES_FOLDER)}")
logger.info(f"MP3_RINGTONES_FOLDER: {os.path.abspath(MP3_RINGTONES_FOLDER)}")
logger.info(f"UPLOAD_FOLDER: {os.path.abspath(UPLOAD_FOLDER)}")
logger.info(f"FRONTEND_FOLDER: {os.path.abspath(FRONTEND_FOLDER)}")

def convert_wav_to_mp3(wav_path, mp3_path):
    """Convert WAV file to MP3 format"""
    try:
        if PYDUB_AVAILABLE:
            audio = AudioSegment.from_wav(wav_path)
            audio.export(mp3_path, format="mp3", bitrate="128k")
            return True
        else:
            logger.warning("pydub not available - cannot convert WAV to MP3")
            return False
    except Exception as e:
        logger.error(f"Error converting WAV to MP3: {e}")
        return False

# Serve the React frontend
@app.route('/')
def serve_frontend():
    """Serve the React frontend"""
    try:
        return send_from_directory(FRONTEND_FOLDER, 'index.html')
    except Exception as e:
        logger.error(f"Error serving frontend: {e}")
        return f"Frontend not found. Please ensure the frontend files are in {FRONTEND_FOLDER}", 404

@app.route('/<path:path>')
def serve_frontend_files(path):
    """Serve static files from the React frontend"""
    try:
        return send_from_directory(FRONTEND_FOLDER, path)
    except Exception as e:
        logger.error(f"Error serving frontend file {path}: {e}")
        return f"File not found: {path}", 404

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        return jsonify({
            'status': 'healthy',
            'ringtones_folder': RINGTONES_FOLDER,
            'wav_ringtones_folder': WAV_RINGTONES_FOLDER,
            'mp3_ringtones_folder': MP3_RINGTONES_FOLDER,
            'upload_folder': UPLOAD_FOLDER,
            'frontend_folder': FRONTEND_FOLDER,
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

# Include all the original API endpoints from the main server.py
# (Copy all the endpoints from the original server.py here)

@app.route('/api/ringtones', methods=['GET'])
def list_ringtones():
    """List all ringtones in the ringtones folders"""
    try:
        ringtones = []
        
        # Scan WAV ringtones folder
        if os.path.exists(WAV_RINGTONES_FOLDER):
            for filename in os.listdir(WAV_RINGTONES_FOLDER):
                if filename.lower().endswith('.wav'):
                    file_path = os.path.join(WAV_RINGTONES_FOLDER, filename)
                    file_stat = os.stat(file_path)
                    
                    # Try to load metadata
                    metadata = None
                    metadata_filename = filename.rsplit('.', 1)[0] + '.json'
                    metadata_path = os.path.join(WAV_RINGTONES_FOLDER, metadata_filename)
                    
                    if os.path.exists(metadata_path):
                        try:
                            with open(metadata_path, 'r') as f:
                                metadata = json.load(f)
                        except Exception as e:
                            logger.warning(f"Failed to load metadata for {filename}: {e}")
                    
                    ringtone_info = {
                        'id': metadata.get('id') if metadata else str(uuid.uuid4()),
                        'name': filename,
                        'size': file_stat.st_size,
                        'created': datetime.fromtimestamp(file_stat.st_ctime).isoformat(),
                        'modified': datetime.fromtimestamp(file_stat.st_mtime).isoformat(),
                        'file_path': file_path,
                        'format': 'wav',
                        'folder': 'wav_ringtones'
                    }
                    
                    # Add metadata if available
                    if metadata:
                        ringtone_info.update({
                            'original_name': metadata.get('original_name'),
                            'start_time': metadata.get('start_time'),
                            'end_time': metadata.get('end_time'),
                            'duration': metadata.get('duration'),
                            'has_metadata': True
                        })
                    else:
                        ringtone_info['has_metadata'] = False
                    
                    ringtones.append(ringtone_info)
        
        # Scan MP3 ringtones folder
        if os.path.exists(MP3_RINGTONES_FOLDER):
            for filename in os.listdir(MP3_RINGTONES_FOLDER):
                if filename.lower().endswith('.mp3'):
                    file_path = os.path.join(MP3_RINGTONES_FOLDER, filename)
                    file_stat = os.stat(file_path)
                    
                    # Try to load metadata
                    metadata = None
                    metadata_filename = filename.rsplit('.', 1)[0] + '.json'
                    metadata_path = os.path.join(MP3_RINGTONES_FOLDER, metadata_filename)
                    
                    if os.path.exists(metadata_path):
                        try:
                            with open(metadata_path, 'r') as f:
                                metadata = json.load(f)
                        except Exception as e:
                            logger.warning(f"Failed to load metadata for {filename}: {e}")
                    
                    ringtone_info = {
                        'id': metadata.get('id') if metadata else str(uuid.uuid4()),
                        'name': filename,
                        'size': file_stat.st_size,
                        'created': datetime.fromtimestamp(file_stat.st_ctime).isoformat(),
                        'modified': datetime.fromtimestamp(file_stat.st_mtime).isoformat(),
                        'file_path': file_path,
                        'format': 'mp3',
                        'folder': 'mp3_ringtones'
                    }
                    
                    # Add metadata if available
                    if metadata:
                        ringtone_info.update({
                            'original_name': metadata.get('original_name'),
                            'start_time': metadata.get('start_time'),
                            'end_time': metadata.get('end_time'),
                            'duration': metadata.get('duration'),
                            'has_metadata': True
                        })
                    else:
                        ringtone_info['has_metadata'] = False
                    
                    ringtones.append(ringtone_info)
        
        return jsonify({
            'success': True,
            'ringtones': ringtones,
            'count': len(ringtones)
        })
    except Exception as e:
        logger.error(f"Error listing ringtones: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# Add all other endpoints from the original server.py here...
# (For brevity, I'm including the key endpoints. You would copy all endpoints)

def open_browser():
    """Open the browser after a short delay"""
    time.sleep(1.5)
    webbrowser.open('http://localhost:5000')

if __name__ == '__main__':
    try:
        logger.info(f"Starting Standalone Ringtone Creator Backend Server")
        logger.info(f"BASE_DIR: {BASE_DIR}")
        logger.info(f"RINGTONES_FOLDER: {RINGTONES_FOLDER}")
        logger.info(f"WAV_RINGTONES_FOLDER: {WAV_RINGTONES_FOLDER}")
        logger.info(f"MP3_RINGTONES_FOLDER: {MP3_RINGTONES_FOLDER}")
        logger.info(f"UPLOAD_FOLDER: {UPLOAD_FOLDER}")
        logger.info(f"FRONTEND_FOLDER: {FRONTEND_FOLDER}")
        logger.info("Server will be available at http://localhost:5000")
        logger.info(f"PYDUB_AVAILABLE: {PYDUB_AVAILABLE}")
        logger.info(f"PYDUB_FULLY_WORKING: {PYDUB_FULLY_WORKING}")
        
        if not PYDUB_AVAILABLE:
            logger.warning("⚠️ MP3 conversion will be disabled - pydub not available")
            logger.warning("💡 To enable MP3 conversion, ensure pydub is installed in the Python environment")
        elif not PYDUB_FULLY_WORKING:
            logger.warning("⚠️ MP3 conversion will be disabled - pydub available but audio conversion not working")
            logger.warning("💡 To fix this, install ffmpeg or similar audio codecs")
        else:
            logger.info("✅ MP3 conversion enabled - pydub is available and working")
        
        # Start browser in a separate thread
        browser_thread = threading.Thread(target=open_browser)
        browser_thread.daemon = True
        browser_thread.start()
        
        app.run(host='127.0.0.1', port=5000, debug=False)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        input("Press Enter to exit...")
        exit(1)
