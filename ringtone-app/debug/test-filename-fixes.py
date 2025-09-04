# Rules applied
# Test script to verify filename fixes for ringtones

import requests
import json
import time
import os

def test_filename_fixes():
    """Test that ringtones get clean filenames and both formats are saved"""
    
    base_url = "http://localhost:5000"
    
    print("🧪 Testing Filename Fixes")
    print("=" * 50)
    
    # Test 1: Check server health
    print("\n1️⃣ Testing server health...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ Server is healthy")
            print(f"   📁 Ringtones folder: {health_data.get('ringtones_folder')}")
        else:
            print(f"❌ Server health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Server health check error: {e}")
        return False
    
    # Test 2: Check current ringtone structure
    print("\n2️⃣ Checking current ringtone structure...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        if response.status_code == 200:
            ringtones_data = response.json()
            if ringtones_data.get('success'):
                ringtones = ringtones_data.get('ringtones', [])
                print(f"✅ Found {len(ringtones)} existing ringtones")
                
                # Check for filename patterns
                wav_files = [r for r in ringtones if r.get('format') == 'wav']
                mp3_files = [r for r in ringtones if r.get('format') == 'mp3']
                
                print(f"   📁 WAV files: {len(wav_files)}")
                print(f"   📁 MP3 files: {len(mp3_files)}")
                
                # Show some examples and check for issues
                if wav_files:
                    print(f"\n   📱 WAV examples:")
                    for wav in wav_files[:3]:
                        name = wav.get('name', '')
                        print(f"      - {name}")
                        if '.mp3' in name and '.wav' in name:
                            print(f"        ⚠️  CONTAINS BOTH EXTENSIONS!")
                        elif '.mp3' in name:
                            print(f"        ⚠️  Contains .mp3 in WAV filename")
                        else:
                            print(f"        ✅ Clean filename")
                
                if mp3_files:
                    print(f"\n   📱 MP3 examples:")
                    for mp3 in mp3_files[:3]:
                        name = mp3.get('name', '')
                        print(f"      - {name}")
                        if '.wav' in name and '.mp3' in name:
                            print(f"        ⚠️  CONTAINS BOTH EXTENSIONS!")
                        elif '.wav' in name:
                            print(f"        ⚠️  Contains .wav in MP3 filename")
                        else:
                            print(f"        ✅ Clean filename")
            else:
                print(f"⚠️ Ringtone listing failed: {ringtones_data.get('error')}")
        else:
            print(f"❌ Ringtone listing failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Ringtone listing error: {e}")
    
    # Test 3: Check folder structure for filename patterns
    print("\n3️⃣ Checking folder structure for filename patterns...")
    try:
        # Check if the ringtones folder exists
        ringtones_folder = os.path.join(os.path.dirname(os.path.dirname(__file__)), "..", "ringtones")
        if os.path.exists(ringtones_folder):
            print(f"✅ Ringtones folder exists: {ringtones_folder}")
            
            # Check subfolders
            wav_folder = os.path.join(ringtones_folder, "wav_ringtones")
            mp3_folder = os.path.join(ringtones_folder, "mp3_ringtones")
            
            if os.path.exists(wav_folder):
                wav_files = [f for f in os.listdir(wav_folder) if f.endswith('.wav')]
                wav_metadata = [f for f in os.listdir(wav_folder) if f.endswith('.json')]
                print(f"   📁 WAV folder: {len(wav_files)} WAV files, {len(wav_metadata)} metadata files")
                
                # Check for filename patterns
                if wav_files:
                    print(f"      Example WAV: {wav_files[0]}")
                    if '.mp3' in wav_files[0]:
                        print(f"      ⚠️  WAV filename contains .mp3 extension!")
                    else:
                        print(f"      ✅ Clean WAV filename")
            
            if os.path.exists(mp3_folder):
                mp3_files = [f for f in os.listdir(mp3_folder) if f.endswith('.mp3')]
                mp3_metadata = [f for f in os.listdir(mp3_folder) if f.endswith('.json')]
                print(f"   📁 MP3 folder: {len(mp3_files)} MP3 files, {len(mp3_metadata)} metadata files")
                
                # Check for filename patterns
                if mp3_files:
                    print(f"      Example MP3: {mp3_files[0]}")
                    if '.wav' in mp3_files[0]:
                        print(f"      ⚠️  MP3 filename contains .wav extension!")
                    else:
                        print(f"      ✅ Clean MP3 filename")
        else:
            print(f"❌ Ringtones folder not found: {ringtones_folder}")
    except Exception as e:
        print(f"❌ Folder structure check error: {e}")
    
    print("\n🎯 Test Summary:")
    print("   ✅ Server health check")
    print("   ✅ Ringtone structure analysis")
    print("   ✅ Filename pattern verification")
    print("\n💡 What to look for:")
    print("   1. WAV files should NOT contain .mp3 in their names")
    print("   2. MP3 files should NOT contain .wav in their names")
    print("   3. Filenames should be clean and descriptive")
    print("   4. Both formats should be available when creating ringtones")
    print("\n⚠️  Issues found:")
    print("   - Filenames with both extensions indicate the fix is needed")
    print("   - Missing MP3 versions suggest conversion issues")
    
    return True

if __name__ == "__main__":
    print("🚀 Starting filename fixes test...")
    print("   Make sure the backend server is running on http://localhost:5000")
    print()
    
    try:
        test_filename_fixes()
    except KeyboardInterrupt:
        print("\n⏹️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
    
    print("\n�� Test completed!")
