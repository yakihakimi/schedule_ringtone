# Rules applied
#!/usr/bin/env python3
"""
Test script to verify MP3 conversion works with the installed ffmpeg
"""

import os
import sys
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

try:
    from pydub import AudioSegment
    from pydub.utils import which
    
    print("🔧 Testing MP3 conversion with pydub...")
    print(f"📁 ffmpeg path: {ffmpeg_path}")
    
    # Check if ffmpeg is found
    ffmpeg_exe = which("ffmpeg")
    print(f"🔍 ffmpeg found at: {ffmpeg_exe}")
    
    # Test MP3 conversion
    print("🔄 Creating test audio...")
    test_audio = AudioSegment.silent(duration=1000)  # 1 second of silence
    
    test_mp3_path = "test_mp3_conversion.mp3"
    print(f"💾 Exporting to MP3: {test_mp3_path}")
    
    test_audio.export(test_mp3_path, format="mp3", bitrate="128k")
    
    # Check if file was created
    if os.path.exists(test_mp3_path):
        file_size = os.path.getsize(test_mp3_path)
        print(f"✅ MP3 conversion successful! File size: {file_size} bytes")
        
        # Clean up test file
        os.remove(test_mp3_path)
        print("🧹 Test file cleaned up")
        
        print("\n🎉 MP3 conversion is working correctly!")
        print("💡 The ringtone creation should now work for both WAV and MP3 formats")
        
    else:
        print("❌ MP3 file was not created")
        
except ImportError as e:
    print(f"❌ Error importing pydub: {e}")
except Exception as e:
    print(f"❌ Error during MP3 conversion test: {e}")
    import traceback
    traceback.print_exc()