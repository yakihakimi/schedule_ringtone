# Rules applied
#!/usr/bin/env python3
"""
Test script to verify dynamic FFmpeg path detection works correctly
"""

import os
import sys
import shutil
from pathlib import Path

def find_ffmpeg_path():
    """Find FFmpeg installation path dynamically"""
    # First, check if ffmpeg is already in PATH
    ffmpeg_exe = shutil.which("ffmpeg")
    if ffmpeg_exe:
        ffmpeg_dir = os.path.dirname(ffmpeg_exe)
        print(f"✅ FFmpeg found in PATH: {ffmpeg_dir}")
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
    
    print("🔍 Searching for FFmpeg in common installation paths...")
    for i, path in enumerate(possible_paths, 1):
        print(f"  {i}. Checking: {path}")
        if os.path.exists(path):
            ffmpeg_exe = os.path.join(path, "ffmpeg.exe")
            if os.path.exists(ffmpeg_exe):
                print(f"✅ FFmpeg found at: {path}")
                return path
            else:
                print(f"   ⚠️ Directory exists but ffmpeg.exe not found")
        else:
            print(f"   ❌ Directory does not exist")
    
    print("❌ FFmpeg not found in any common installation paths")
    return None

def test_ffmpeg_functionality(ffmpeg_path):
    """Test if FFmpeg is working correctly"""
    if not ffmpeg_path:
        return False
    
    ffmpeg_exe = os.path.join(ffmpeg_path, "ffmpeg.exe")
    if not os.path.exists(ffmpeg_exe):
        print(f"❌ ffmpeg.exe not found at: {ffmpeg_exe}")
        return False
    
    try:
        import subprocess
        print(f"🧪 Testing FFmpeg functionality...")
        result = subprocess.run([ffmpeg_exe, "-version"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            version_line = result.stdout.split('\n')[0]
            print(f"✅ FFmpeg is working correctly!")
            print(f"🔍 Version: {version_line}")
            return True
        else:
            print(f"❌ FFmpeg test failed with return code: {result.returncode}")
            print(f"Error output: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print("❌ FFmpeg test timed out")
        return False
    except Exception as e:
        print(f"❌ Error testing FFmpeg: {e}")
        return False

def test_pydub_integration(ffmpeg_path):
    """Test if pydub can use the found FFmpeg"""
    if not ffmpeg_path:
        return False
    
    try:
        # Add FFmpeg to PATH temporarily
        original_path = os.environ.get("PATH", "")
        os.environ["PATH"] = ffmpeg_path + os.pathsep + original_path
        
        from pydub import AudioSegment
        from pydub.utils import which
        
        print("🧪 Testing pydub integration...")
        
        # Check if pydub can find ffmpeg
        ffmpeg_exe = which("ffmpeg")
        if ffmpeg_exe:
            print(f"✅ pydub found FFmpeg at: {ffmpeg_exe}")
        else:
            print("❌ pydub could not find FFmpeg")
            return False
        
        # Test basic audio conversion
        print("🧪 Testing audio conversion...")
        test_audio = AudioSegment.silent(duration=1000)  # 1 second of silence
        test_path = "test_ffmpeg_detection.mp3"
        
        try:
            test_audio.export(test_path, format="mp3", bitrate="128k")
            if os.path.exists(test_path) and os.path.getsize(test_path) > 0:
                print("✅ Audio conversion test successful!")
                os.remove(test_path)  # Clean up
                return True
            else:
                print("❌ Audio conversion test failed - no output file")
                return False
        except Exception as e:
            print(f"❌ Audio conversion test failed: {e}")
            return False
        
    except ImportError:
        print("❌ pydub not available")
        return False
    except Exception as e:
        print(f"❌ Error testing pydub integration: {e}")
        return False
    finally:
        # Restore original PATH
        os.environ["PATH"] = original_path

def main():
    """Main test function"""
    print("=" * 60)
    print("🧪 FFMPEG DETECTION TEST")
    print("=" * 60)
    print("")
    
    # Test 1: Find FFmpeg path
    print("🔍 Test 1: Finding FFmpeg installation...")
    ffmpeg_path = find_ffmpeg_path()
    print("")
    
    if not ffmpeg_path:
        print("❌ FFmpeg not found!")
        print("")
        print("💡 To install FFmpeg:")
        print("   1. Run: debug/install-ffmpeg-portable.py")
        print("   2. Or run: debug/install-ffmpeg-portable.ps1")
        print("   3. Or install system-wide using winget: winget install Gyan.FFmpeg")
        return False
    
    # Test 2: Test FFmpeg functionality
    print("🔍 Test 2: Testing FFmpeg functionality...")
    ffmpeg_working = test_ffmpeg_functionality(ffmpeg_path)
    print("")
    
    if not ffmpeg_working:
        print("❌ FFmpeg found but not working properly!")
        return False
    
    # Test 3: Test pydub integration
    print("🔍 Test 3: Testing pydub integration...")
    pydub_working = test_pydub_integration(ffmpeg_path)
    print("")
    
    # Summary
    print("=" * 60)
    print("📋 TEST SUMMARY")
    print("=" * 60)
    print(f"FFmpeg Path: {ffmpeg_path}")
    print(f"FFmpeg Working: {'✅ Yes' if ffmpeg_working else '❌ No'}")
    print(f"pydub Integration: {'✅ Yes' if pydub_working else '❌ No'}")
    print("")
    
    if ffmpeg_working and pydub_working:
        print("🎉 All tests passed! FFmpeg is ready for use.")
        print("💡 The backend should now be able to convert audio files.")
        return True
    else:
        print("❌ Some tests failed. FFmpeg may not work properly.")
        return False

if __name__ == "__main__":
    success = main()
    print("")
    input("Press Enter to continue...")
    sys.exit(0 if success else 1)
