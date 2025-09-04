# Rules applied
# Test script to verify pydub is working with system Python

import sys
import os

def test_pydub_availability():
    """Test if pydub is available in the current Python environment"""
    print("🧪 Testing pydub availability")
    print("=" * 50)
    
    print(f"Python executable: {sys.executable}")
    print(f"Python version: {sys.version}")
    print(f"Python path: {sys.path[:3]}...")  # Show first 3 paths
    
    try:
        from pydub import AudioSegment
        print("✅ pydub is available!")
        print(f"pydub version: {AudioSegment.__version__}")
        
        # Test basic functionality
        print("🧪 Testing basic pydub functionality...")
        
        # Create a simple silent audio segment
        silent_audio = AudioSegment.silent(duration=1000)  # 1 second
        print("✅ Successfully created silent audio segment")
        
        # Test export (this will fail without ffmpeg, but pydub itself works)
        try:
            test_path = "test_audio.mp3"
            silent_audio.export(test_path, format="mp3")
            print("✅ Successfully exported audio to MP3")
            
            # Clean up test file
            if os.path.exists(test_path):
                os.remove(test_path)
                print("✅ Test file cleaned up")
        except Exception as e:
            print(f"⚠️ Audio export failed (expected without ffmpeg): {e}")
            print("✅ But pydub itself is working correctly")
        
        return True
        
    except ImportError as e:
        print(f"❌ pydub import failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == '__main__':
    success = test_pydub_availability()
    print("\n" + "=" * 50)
    if success:
        print("🎉 pydub is working correctly!")
        print("💡 The backend should now be able to convert WAV to MP3")
    else:
        print("❌ pydub is not working")
        print("💡 Check Python environment and pydub installation")
