# Rules applied
import os
import sys
import tempfile

# Add the backend directory to the path so we can import the server functions
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'portable_app', 'backend'))

def test_mp3_conversion():
    """Test MP3 conversion functionality"""
    print("🔍 Testing MP3 conversion functionality...")
    
    try:
        from pydub import AudioSegment
        
        # Configure FFmpeg path
        ffmpeg_path = os.path.join(os.path.dirname(__file__), '..', 'portable_app', 'ffmpeg', 'bin')
        ffmpeg_exe = os.path.join(ffmpeg_path, 'ffmpeg.exe')
        ffprobe_exe = os.path.join(ffmpeg_path, 'ffprobe.exe')
        
        if os.path.exists(ffmpeg_exe):
            AudioSegment.converter = ffmpeg_exe
            AudioSegment.ffmpeg = ffmpeg_exe
            AudioSegment.ffprobe = ffprobe_exe
            print(f"✅ Configured pydub to use FFmpeg: {ffmpeg_exe}")
        else:
            print(f"❌ FFmpeg not found at: {ffmpeg_exe}")
            return False
        
        # Create a test audio file
        print("🎵 Creating test audio...")
        test_audio = AudioSegment.silent(duration=2000)  # 2 seconds of silence
        
        # Test WAV export
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as wav_file:
            wav_path = wav_file.name
        
        print("🔄 Testing WAV export...")
        test_audio.export(wav_path, format="wav")
        
        if os.path.exists(wav_path) and os.path.getsize(wav_path) > 0:
            print(f"✅ WAV export successful: {os.path.getsize(wav_path)} bytes")
        else:
            print("❌ WAV export failed")
            return False
        
        # Test MP3 export
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as mp3_file:
            mp3_path = mp3_file.name
        
        print("🔄 Testing MP3 export...")
        test_audio.export(mp3_path, format="mp3", bitrate="128k")
        
        if os.path.exists(mp3_path) and os.path.getsize(mp3_path) > 0:
            print(f"✅ MP3 export successful: {os.path.getsize(mp3_path)} bytes")
        else:
            print("❌ MP3 export failed")
            return False
        
        # Test WAV to MP3 conversion
        print("🔄 Testing WAV to MP3 conversion...")
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as converted_file:
            converted_path = converted_file.name
        
        # Load WAV and convert to MP3
        loaded_audio = AudioSegment.from_wav(wav_path)
        loaded_audio.export(converted_path, format="mp3", bitrate="128k")
        
        if os.path.exists(converted_path) and os.path.getsize(converted_path) > 0:
            print(f"✅ WAV to MP3 conversion successful: {os.path.getsize(converted_path)} bytes")
        else:
            print("❌ WAV to MP3 conversion failed")
            return False
        
        # Clean up test files
        try:
            os.unlink(wav_path)
            os.unlink(mp3_path)
            os.unlink(converted_path)
            print("🧹 Cleaned up test files")
        except Exception as e:
            print(f"⚠️ Warning: Could not clean up test files: {e}")
        
        return True
        
    except ImportError as e:
        print(f"❌ pydub not available: {e}")
        return False
    except Exception as e:
        print(f"❌ MP3 conversion test failed: {e}")
        return False

if __name__ == "__main__":
    success = test_mp3_conversion()
    if success:
        print("\n🎉 MP3 conversion test PASSED!")
        print("✅ FFmpeg is properly configured and MP3 conversion is working!")
    else:
        print("\n💥 MP3 conversion test FAILED!")
        print("❌ FFmpeg configuration or MP3 conversion is not working!")
        sys.exit(1)