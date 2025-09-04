# Rules applied
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import os
import uuid
from datetime import datetime
import logging
import json

# Configure ffmpeg path for pydub
def find_ffmpeg_path():
    """Find FFmpeg installation path dynamically"""
    import shutil
    
    # First, check if ffmpeg is already in PATH
    ffmpeg_exe = shutil.which("ffmpeg")
    if ffmpeg_exe:
        ffmpeg_dir = os.path.dirname(ffmpeg_exe)
        logging.info(f"FFmpeg found in PATH: {ffmpeg_dir}")
        return ffmpeg_dir
    
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
        os.path.join(os.path.dirname(__file__), "ffmpeg", "bin"),
        # Project root ffmpeg folder
        os.path.join(os.path.dirname(os.path.dirname(__file__)), "ffmpeg", "bin")
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

# Configuration
RINGTONES_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'ringtones')
WAV_RINGTONES_FOLDER = os.path.join(RINGTONES_FOLDER, 'wav_ringtones')
MP3_RINGTONES_FOLDER = os.path.join(RINGTONES_FOLDER, 'mp3_ringtones')
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'original_sound')

# Ensure directories exist
os.makedirs(RINGTONES_FOLDER, exist_ok=True)
os.makedirs(WAV_RINGTONES_FOLDER, exist_ok=True)
os.makedirs(MP3_RINGTONES_FOLDER, exist_ok=True)
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Log the actual paths being used
logger.info(f"RINGTONES_FOLDER: {os.path.abspath(RINGTONES_FOLDER)}")
logger.info(f"WAV_RINGTONES_FOLDER: {os.path.abspath(WAV_RINGTONES_FOLDER)}")
logger.info(f"MP3_RINGTONES_FOLDER: {os.path.abspath(MP3_RINGTONES_FOLDER)}")
logger.info(f"UPLOAD_FOLDER: {os.path.abspath(UPLOAD_FOLDER)}")

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
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

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

@app.route('/api/ringtones', methods=['POST'])
def save_ringtone():
    """Save a ringtone file to the mp3_ringtones folder (MP3 only for now)"""
    try:
        print("🎵 RINGTONE CREATION STARTED!")
        print(f"📥 Request files: {list(request.files.keys())}")
        print(f"📥 Request form data: {dict(request.form)}")
        
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'No file selected'}), 400
        
        # Get metadata from form data
        original_name = request.form.get('original_name', 'Unknown')
        start_time = request.form.get('start_time', '0')
        end_time = request.form.get('end_time', '0')
        duration = request.form.get('duration', '0')
        
        # Clean the original name to remove file extensions
        clean_original_name = original_name
        for ext in ['.mp3', '.wav', '.m4a', '.ogg']:
            clean_original_name = clean_original_name.replace(ext, '')
        
        # Validate file type - Accept MP3 and WAV for now
        file_ext = os.path.splitext(file.filename)[1].lower()
        if file_ext not in ['.mp3', '.wav']:
            return jsonify({'success': False, 'error': 'Only MP3 and WAV files are supported. Please upload an MP3 or WAV file.'}), 400
        
        # Generate unique filename with clean original name info
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        safe_filename = f"ringtone_{timestamp}_{clean_original_name}_{start_time}s_to_{end_time}s{file_ext}"
        safe_filename = "".join(c for c in safe_filename if c.isalnum() or c in (' ', '-', '_', '.')).rstrip()
        
        # Determine which folder to save to based on file type
        if file_ext.lower() == '.wav':
            target_folder = WAV_RINGTONES_FOLDER
            target_filename = safe_filename
        else:
            target_folder = MP3_RINGTONES_FOLDER
            target_filename = safe_filename
        
        file_path = os.path.join(target_folder, target_filename)
        
        # Log the exact file path being used
        logger.info(f"Saving {file_ext.upper()} ringtone to: {os.path.abspath(file_path)}")
        
        # Save file
        file.save(file_path)
        print(f"💾 {file_ext.upper()} file saved successfully to: {os.path.abspath(file_path)}")
        
        # Generate base filename without extension for MP3 conversion
        base_filename = safe_filename.rsplit('.', 1)[0]
        
        # Always create MP3 version regardless of input format
        mp3_filename = f"{base_filename}.mp3"
        mp3_path = os.path.join(MP3_RINGTONES_FOLDER, mp3_filename)
        
        mp3_created = False
        mp3_metadata = None
        
        try:
            if PYDUB_AVAILABLE and PYDUB_FULLY_WORKING:
                print("🔄 Starting MP3 conversion...")
                logger.info("Starting MP3 conversion process")
                
                # Convert to MP3
                if file_ext.lower() == '.wav':
                    # If input is WAV, convert directly
                    print("📥 Loading WAV file for conversion...")
                    audio = AudioSegment.from_wav(file_path)
                    print(f"✅ WAV file loaded successfully. Duration: {len(audio)}ms")
                else:
                    # If input is MP3, load and re-export to ensure consistency
                    print("📥 Loading MP3 file for re-export...")
                    audio = AudioSegment.from_mp3(file_path)
                    print(f"✅ MP3 file loaded successfully. Duration: {len(audio)}ms")
                
                # Export as MP3
                print("🔄 Exporting to MP3 format...")
                audio.export(mp3_path, format="mp3", bitrate="128k")
                
                # Verify the MP3 file was created and has content
                if os.path.exists(mp3_path):
                    mp3_size = os.path.getsize(mp3_path)
                    if mp3_size > 0:
                        mp3_created = True
                        print(f"✅ MP3 file created successfully! Size: {mp3_size} bytes")
                        
                        # Create MP3 metadata
                        mp3_metadata = {
                            'id': str(uuid.uuid4()),
                            'filename': mp3_filename,
                            'original_name': clean_original_name,
                            'start_time': float(start_time),
                            'end_time': float(end_time),
                            'duration': float(duration),
                            'created': datetime.now().isoformat(),
                            'file_path': mp3_path,
                            'format': 'mp3',
                            'folder': 'mp3_ringtones',
                            'file_size': mp3_size
                        }
                        
                        # Save MP3 metadata
                        mp3_metadata_filename = mp3_filename.rsplit('.', 1)[0] + '.json'
                        mp3_metadata_path = os.path.join(MP3_RINGTONES_FOLDER, mp3_metadata_filename)
                        with open(mp3_metadata_path, 'w') as f:
                            json.dump(mp3_metadata, f, indent=2)
                        
                        print(f"🎵 MP3 version created successfully: {os.path.abspath(mp3_path)}")
                        print(f"🎯 DUAL FORMAT SUCCESS: Both WAV and MP3 ringtones are now available!")
                        logger.info(f"✅ MP3 version created: {mp3_filename} (Size: {mp3_size} bytes)")
                    else:
                        print(f"❌ MP3 file created but is empty (0 bytes)")
                        logger.error(f"MP3 file created but is empty: {mp3_filename}")
                        # Clean up empty file
                        os.remove(mp3_path)
                        if os.path.exists(mp3_metadata_path):
                            os.remove(mp3_metadata_path)
                else:
                    print(f"❌ MP3 file was not created")
                    logger.error(f"MP3 file was not created: {mp3_filename}")
                    
            elif PYDUB_AVAILABLE and not PYDUB_FULLY_WORKING:
                print("⚠️ pydub available but audio conversion not working - missing audio codecs")
                print("💡 To fix this, install ffmpeg or similar audio codecs")
                logger.warning("pydub available but audio conversion not working - missing audio codecs")
            else:
                print("⚠️ pydub not available - MP3 conversion skipped")
                logger.warning("pydub not available - MP3 conversion skipped")
        except Exception as e:
            print(f"❌ Error creating MP3 version: {e}")
            logger.error(f"Error creating MP3 version: {e}")
            
            # Clean up any partial files
            if os.path.exists(mp3_path):
                os.remove(mp3_path)
                print(f"🧹 Cleaned up partial MP3 file: {mp3_filename}")
            if 'mp3_metadata_path' in locals() and os.path.exists(mp3_metadata_path):
                os.remove(mp3_metadata_path)
                print(f"🧹 Cleaned up partial MP3 metadata")
        
        # Save metadata to a JSON file for original format
        metadata = {
            'id': str(uuid.uuid4()),
            'filename': target_filename,
            'original_name': clean_original_name,
            'start_time': float(start_time),
            'end_time': float(end_time),
            'duration': float(duration),
            'created': datetime.now().isoformat(),
            'file_path': file_path,
            'format': file_ext.lower().replace('.', ''),
            'folder': os.path.basename(target_folder),
            'mp3_available': mp3_created,
            'mp3_filename': mp3_filename if mp3_created else None,
            'mp3_path': mp3_path if mp3_created else None
        }
        
        metadata_filename = target_filename.rsplit('.', 1)[0] + '.json'
        metadata_path = os.path.join(target_folder, metadata_filename)
        
        with open(metadata_path, 'w') as f:
            json.dump(metadata, f, indent=2)
        
        # Get file info
        file_stat = os.stat(file_path)
        
        # Print success message
        print("=" * 60)
        print(f"🎵 SUCCESS: Ringtone created successfully!")
        print("=" * 60)
        print(f"📁 {file_ext.upper()} format saved to: {os.path.basename(target_folder)}")
        print(f"📁 {file_ext.upper()} filename: {target_filename}")
        
        if mp3_created:
            print("")
            print(f"🎵 MP3 format also created successfully!")
            print(f"📁 MP3 saved to: mp3_ringtones")
            print(f"📁 MP3 filename: {mp3_filename}")
            print("")
            print(f"✅ Both WAV and MP3 formats are now available!")
            print("")
            print("📋 SUMMARY:")
            print(f"   • WAV: {os.path.basename(target_folder)}/{target_filename}")
            print(f"   • MP3: mp3_ringtones/{mp3_filename}")
            print("=" * 60)
        else:
            print("")
            print("⚠️ MP3 version creation failed or skipped")
            print("💡 Only WAV format was created")
            print("=" * 60)
        
        logger.info(f"✅ {file_ext.upper()} ringtone saved successfully: {target_filename}")
        logger.info(f"📁 File path: {os.path.abspath(file_path)}")
        if mp3_created:
            logger.info(f"✅ MP3 version created successfully: {mp3_filename}")
            logger.info(f"📁 MP3 file path: {os.path.abspath(mp3_path)}")
        else:
            logger.warning("MP3 version creation failed or skipped")
        
        # Create response data
        response_data = {
            'success': True,
            'message': f'Ringtone created successfully in both WAV and MP3 formats!' if mp3_created else f'{file_ext.upper()} ringtone created successfully!',
            'filename': target_filename,
            'file_path': file_path,
            'size': file_stat.st_size,
            'created': datetime.fromtimestamp(file_stat.st_ctime).isoformat(),
            'metadata': metadata,
            'format': file_ext.lower().replace('.', ''),
            'folder': os.path.basename(target_folder),
            'mp3_available': mp3_created,
            'mp3_filename': mp3_filename if mp3_created else None,
            'mp3_path': mp3_path if mp3_created else None,
            'mp3_created': mp3_created,
            'mp3_metadata': mp3_metadata
        }
        
        # Log the response being sent
        logger.info(f"📤 Sending response: {response_data}")
        
        return jsonify(response_data)
        
    except Exception as e:
        logger.error(f"Error saving ringtone: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/ringtones/<folder>/<filename>', methods=['GET'])
def download_ringtone(folder, filename):
    """Download a ringtone file from the specified folder"""
    try:
        # Validate folder name for security
        if folder not in ['wav_ringtones', 'mp3_ringtones']:
            return jsonify({'success': False, 'error': 'Invalid folder'}), 400
        
        file_path = os.path.join(RINGTONES_FOLDER, folder, filename)
        if not os.path.exists(file_path):
            return jsonify({'success': False, 'error': 'File not found'}), 404
        
        return send_file(file_path, as_attachment=True)
        
    except Exception as e:
        logger.error(f"Error downloading ringtone: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/ringtones/<folder>/<filename>', methods=['DELETE'])
def delete_ringtone(folder, filename):
    """Delete a ringtone file from the specified folder"""
    try:
        # Validate folder name for security
        if folder not in ['wav_ringtones', 'mp3_ringtones']:
            return jsonify({'success': False, 'error': 'Invalid folder'}), 400
        
        file_path = os.path.join(RINGTONES_FOLDER, folder, filename)
        if not os.path.exists(file_path):
            return jsonify({'success': False, 'error': 'File not found'}), 404
        
        # Delete the main file
        os.remove(file_path)
        
        # Try to delete metadata file
        metadata_filename = filename.rsplit('.', 1)[0] + '.json'
        metadata_path = os.path.join(RINGTONES_FOLDER, folder, metadata_filename)
        if os.path.exists(metadata_path):
            os.remove(metadata_path)
            logger.info(f"Metadata deleted: {metadata_filename}")
        
        # If deleting from WAV folder, also try to delete corresponding MP3
        if folder == 'wav_ringtones':
            mp3_filename = filename.rsplit('.', 1)[0] + '.mp3'
            mp3_path = os.path.join(MP3_RINGTONES_FOLDER, mp3_filename)
            if os.path.exists(mp3_path):
                os.remove(mp3_path)
                logger.info(f"Corresponding MP3 deleted: {mp3_filename}")
                
                # Also delete MP3 metadata
                mp3_metadata_filename = mp3_filename.rsplit('.', 1)[0] + '.json'
                mp3_metadata_path = os.path.join(MP3_RINGTONES_FOLDER, mp3_metadata_filename)
                if os.path.exists(mp3_metadata_path):
                    os.remove(mp3_metadata_path)
                    logger.info(f"MP3 metadata deleted: {mp3_metadata_filename}")
        
        # If deleting from MP3 folder, also try to delete corresponding WAV
        elif folder == 'mp3_ringtones':
            wav_filename = filename.rsplit('.', 1)[0] + '.wav'
            wav_path = os.path.join(WAV_RINGTONES_FOLDER, wav_filename)
            if os.path.exists(wav_path):
                os.remove(wav_path)
                logger.info(f"Corresponding WAV deleted: {wav_filename}")
                
                # Also delete WAV metadata
                wav_metadata_filename = wav_filename.rsplit('.', 1)[0] + '.json'
                wav_metadata_path = os.path.join(WAV_RINGTONES_FOLDER, wav_metadata_filename)
                if os.path.exists(wav_metadata_path):
                    os.remove(wav_metadata_path)
                    logger.info(f"WAV metadata deleted: {wav_metadata_filename}")
        
        logger.info(f"Ringtone deleted successfully: {filename} from {folder}")
        
        return jsonify({
            'success': True,
            'message': 'Ringtone deleted successfully',
            'filename': filename,
            'folder': folder
        })
        
    except Exception as e:
        logger.error(f"Error deleting ringtone: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/upload', methods=['POST'])
def upload_audio():
    """Upload an original MP3 or WAV audio file"""
    try:
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'success': False, 'error': 'No file selected'}), 400
        
        # Validate file type - Accept MP3 and WAV for now
        file_ext = os.path.splitext(file.filename)[1].lower()
        if file_ext not in ['.mp3', '.wav']:
            return jsonify({'success': False, 'error': 'Only MP3 and WAV files are supported. Please upload an MP3 or WAV file.'}), 400
        
        # Save file
        file_path = os.path.join(UPLOAD_FOLDER, file.filename)
        file.save(file_path)
        
        # Get file info
        file_stat = os.stat(file_path)
        
        logger.info(f"{file_ext.upper()} audio file uploaded successfully: {file.filename}")
        
        return jsonify({
            'success': True,
            'message': f'{file_ext.upper()} audio file uploaded successfully',
            'filename': file.filename,
            'file_path': file_path,
            'size': file_stat.st_size,
            'uploaded': datetime.fromtimestamp(file_stat.st_ctime).isoformat()
        })
        
    except Exception as e:
        logger.error(f"Error uploading audio file: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

# Windows Task Scheduler endpoints
@app.route('/api/task-scheduler/status', methods=['GET'])
def task_scheduler_status():
    """Check if Windows Task Scheduler service is available"""
    try:
        return jsonify({
            'success': True,
            'available': TASK_SCHEDULER_AVAILABLE,
            'message': 'Windows Task Scheduler service is available' if TASK_SCHEDULER_AVAILABLE else 'Windows Task Scheduler service is not available'
        })
    except Exception as e:
        logger.error(f"Error checking task scheduler status: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/create', methods=['POST'])
def create_scheduled_task():
    """Create a Windows scheduled task for a ringtone"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'No data provided'}), 400
        
        # Validate required fields
        required_fields = ['task_name', 'ringtone_path', 'time', 'days']
        for field in required_fields:
            if field not in data:
                return jsonify({'success': False, 'error': f'Missing required field: {field}'}), 400
        
        task_name = data['task_name']
        ringtone_path = data['ringtone_path']
        time = data['time']
        days = data['days']
        
        # Validate that the ringtone file exists
        if not os.path.exists(ringtone_path):
            return jsonify({'success': False, 'error': 'Ringtone file not found'}), 404
        
        # Create the scheduled task
        success = task_scheduler_service.create_scheduled_task(task_name, ringtone_path, time, days)
        
        if success:
            logger.info(f"✅ Created Windows scheduled task: {task_name}")
            return jsonify({
                'success': True,
                'message': f'Scheduled task "{task_name}" created successfully',
                'task_name': task_name
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to create scheduled task'}), 500
            
    except Exception as e:
        logger.error(f"Error creating scheduled task: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/delete', methods=['POST'])
def delete_scheduled_task():
    """Delete a Windows scheduled task"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        data = request.get_json()
        if not data or 'task_name' not in data:
            return jsonify({'success': False, 'error': 'Task name is required'}), 400
        
        task_name = data['task_name']
        
        # Delete the scheduled task
        success = task_scheduler_service.delete_scheduled_task(task_name)
        
        if success:
            logger.info(f"✅ Deleted Windows scheduled task: {task_name}")
            return jsonify({
                'success': True,
                'message': f'Scheduled task "{task_name}" deleted successfully',
                'task_name': task_name
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to delete scheduled task'}), 500
            
    except Exception as e:
        logger.error(f"Error deleting scheduled task: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/enable', methods=['POST'])
def enable_scheduled_task():
    """Enable a Windows scheduled task"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        data = request.get_json()
        if not data or 'task_name' not in data:
            return jsonify({'success': False, 'error': 'Task name is required'}), 400
        
        task_name = data['task_name']
        
        # Enable the scheduled task
        success = task_scheduler_service.enable_scheduled_task(task_name)
        
        if success:
            logger.info(f"✅ Enabled Windows scheduled task: {task_name}")
            return jsonify({
                'success': True,
                'message': f'Scheduled task "{task_name}" enabled successfully',
                'task_name': task_name
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to enable scheduled task'}), 500
            
    except Exception as e:
        logger.error(f"Error enabling scheduled task: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/disable', methods=['POST'])
def disable_scheduled_task():
    """Disable a Windows scheduled task"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        data = request.get_json()
        if not data or 'task_name' not in data:
            return jsonify({'success': False, 'error': 'Task name is required'}), 400
        
        task_name = data['task_name']
        
        # Disable the scheduled task
        success = task_scheduler_service.disable_scheduled_task(task_name)
        
        if success:
            logger.info(f"✅ Disabled Windows scheduled task: {task_name}")
            return jsonify({
                'success': True,
                'message': f'Scheduled task "{task_name}" disabled successfully',
                'task_name': task_name
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to disable scheduled task'}), 500
            
    except Exception as e:
        logger.error(f"Error disabling scheduled task: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/test', methods=['POST'])
def test_ringtone_playback():
    """Test playing a ringtone immediately"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        data = request.get_json()
        if not data or 'ringtone_path' not in data:
            return jsonify({'success': False, 'error': 'Ringtone path is required'}), 400
        
        ringtone_path = data['ringtone_path']
        
        # Validate that the ringtone file exists
        if not os.path.exists(ringtone_path):
            return jsonify({'success': False, 'error': 'Ringtone file not found'}), 404
        
        # Test playing the ringtone
        success = task_scheduler_service.test_ringtone_playback(ringtone_path)
        
        if success:
            logger.info(f"✅ Tested ringtone playback: {ringtone_path}")
            return jsonify({
                'success': True,
                'message': 'Ringtone test played successfully',
                'ringtone_path': ringtone_path
            })
        else:
            return jsonify({'success': False, 'error': 'Failed to play ringtone test'}), 500
            
    except Exception as e:
        logger.error(f"Error testing ringtone playback: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/task-scheduler/list', methods=['GET'])
def list_scheduled_tasks():
    """List all ringtone scheduler tasks"""
    try:
        if not TASK_SCHEDULER_AVAILABLE:
            return jsonify({'success': False, 'error': 'Windows Task Scheduler service is not available'}), 503
        
        # List all tasks
        tasks = task_scheduler_service.list_all_tasks()
        
        logger.info(f"✅ Listed {len(tasks)} scheduled tasks")
        return jsonify({
            'success': True,
            'tasks': tasks,
            'count': len(tasks)
        })
            
    except Exception as e:
        logger.error(f"Error listing scheduled tasks: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

if __name__ == '__main__':
    try:
        logger.info(f"Starting Ringtone Creator Backend Server")
        logger.info(f"RINGTONES_FOLDER: {RINGTONES_FOLDER}")
        logger.info(f"WAV_RINGTONES_FOLDER: {WAV_RINGTONES_FOLDER}")
        logger.info(f"MP3_RINGTONES_FOLDER: {MP3_RINGTONES_FOLDER}")
        logger.info(f"UPLOAD_FOLDER: {UPLOAD_FOLDER}")
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
        
        app.run(host='0.0.0.0', port=5000, debug=True)
    except Exception as e:
        logger.error(f"Failed to start server: {e}")
        exit(1)
