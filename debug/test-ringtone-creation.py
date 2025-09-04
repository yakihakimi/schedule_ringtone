# Rules applied
#!/usr/bin/env python3
"""
Test script to verify ringtone creation with MP3 conversion works
"""

import os
import sys
import requests
from pathlib import Path

# Add the ffmpeg path to the environment
def find_ffmpeg_path():
    """Find FFmpeg installation path dynamically"""
    import shutil
    
    # First, check if ffmpeg is already in PATH
    ffmpeg_exe = shutil.which("ffmpeg")
    if ffmpeg_exe:
        ffmpeg_dir = os.path.dirname(ffmpeg_exe)
        print(f"FFmpeg found in PATH: {ffmpeg_dir}")
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
        os.path.join(os.path.dirname(__file__), "..", "backend", "ffmpeg", "bin"),
        # Project root ffmpeg folder
        os.path.join(os.path.dirname(__file__), "..", "ffmpeg", "bin")
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            ffmpeg_exe = os.path.join(path, "ffmpeg.exe")
            if os.path.exists(ffmpeg_exe):
                print(f"FFmpeg found at: {path}")
                return path
    
    print("FFmpeg not found in any common installation paths")
    return None

ffmpeg_path = find_ffmpeg_path()
if ffmpeg_path:
    os.environ["PATH"] = ffmpeg_path + os.pathsep + os.environ.get("PATH", "")
    print(f"Added ffmpeg to PATH: {ffmpeg_path}")
else:
    print("FFmpeg not found - MP3 conversion may not work")

def test_ringtone_creation():
    """Test ringtone creation with MP3 conversion"""
    
    print("🔧 Testing ringtone creation with MP3 conversion...")
    
    # Check if we have an original sound file to test with
    original_sound_dir = Path("original_sound")
    if not original_sound_dir.exists():
        print("❌ No original_sound directory found")
        return False
    
    # Find an MP3 file to test with
    mp3_files = list(original_sound_dir.glob("*.mp3"))
    if not mp3_files:
        print("❌ No MP3 files found in original_sound directory")
        return False
    
    test_file = mp3_files[0]
    print(f"📁 Using test file: {test_file.name}")
    
    # Test the backend API
    try:
        url = "http://localhost:5000/api/ringtones"
        
        # Prepare the form data
        files = {'file': open(test_file, 'rb')}
        data = {
            'original_name': test_file.stem,
            'start_time': '10.0',
            'end_time': '20.0',
            'duration': '10.0'
        }
        
        print("🔄 Sending request to backend...")
        response = requests.post(url, files=files, data=data)
        files['file'].close()
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Ringtone creation successful!")
            print(f"📁 WAV format: {result.get('filename', 'N/A')}")
            print(f"📁 MP3 available: {result.get('mp3_available', False)}")
            
            if result.get('mp3_available'):
                print(f"🎵 MP3 format: {result.get('mp3_filename', 'N/A')}")
                print("🎉 Both WAV and MP3 formats created successfully!")
                return True
            else:
                print("⚠️ Only WAV format was created")
                return False
        else:
            print(f"❌ Request failed with status {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error during test: {e}")
        return False

if __name__ == "__main__":
    success = test_ringtone_creation()
    if success:
        print("\n🎉 MP3 conversion is working correctly!")
        print("💡 The ringtone creation should now work for both WAV and MP3 formats")
    else:
        print("\n❌ MP3 conversion test failed")
        print("💡 Check the backend logs for more details")