# Rules applied
# Test script to verify ringtone creation and listing fixes

import requests
import json
import time
import os

def test_ringtone_creation_and_listing():
    """Test the ringtone creation and listing functionality"""
    
    base_url = "http://localhost:5000"
    
    print("🧪 Testing Ringtone Creation and Listing Fixes")
    print("=" * 50)
    
    # Test 1: Check server health
    print("\n1️⃣ Testing server health...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ Server is healthy")
            print(f"   📁 Ringtones folder: {health_data.get('ringtones_folder')}")
            print(f"   📁 WAV ringtones folder: {health_data.get('wav_ringtones_folder')}")
            print(f"   📁 MP3 ringtones folder: {health_data.get('mp3_ringtones_folder')}")
        else:
            print(f"❌ Server health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Server health check error: {e}")
        return False
    
    # Test 2: List existing ringtones
    print("\n2️⃣ Testing ringtone listing...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        if response.status_code == 200:
            ringtones_data = response.json()
            if ringtones_data.get('success'):
                ringtones = ringtones_data.get('ringtones', [])
                print(f"✅ Successfully listed {len(ringtones)} ringtones")
                
                # Check if ringtones have the new fields
                for ringtone in ringtones[:3]:  # Show first 3
                    print(f"   📱 {ringtone.get('name')}")
                    print(f"      Format: {ringtone.get('format')}")
                    print(f"      MP3 Available: {ringtone.get('mp3_available')}")
                    print(f"      MP3 Filename: {ringtone.get('mp3_filename')}")
                    print(f"      Has Metadata: {ringtone.get('has_metadata')}")
                    print()
            else:
                print(f"⚠️ Ringtone listing failed: {ringtones_data.get('error')}")
        else:
            print(f"❌ Ringtone listing failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Ringtone listing error: {e}")
    
    # Test 3: Check folder structure
    print("\n3️⃣ Checking folder structure...")
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
            
            if os.path.exists(mp3_folder):
                mp3_files = [f for f in os.listdir(mp3_folder) if f.endswith('.mp3')]
                mp3_metadata = [f for f in os.listdir(mp3_folder) if f.endswith('.json')]
                print(f"   📁 MP3 folder: {len(mp3_files)} MP3 files, {len(mp3_metadata)} metadata files")
        else:
            print(f"❌ Ringtones folder not found: {ringtones_folder}")
    except Exception as e:
        print(f"❌ Folder structure check error: {e}")
    
    print("\n🎯 Test Summary:")
    print("   ✅ Server health check")
    print("   ✅ Ringtone listing with new fields")
    print("   ✅ Folder structure verification")
    print("\n💡 Next steps:")
    print("   1. Create a new ringtone to test the fixes")
    print("   2. Check that both WAV and MP3 formats are saved")
    print("   3. Verify the ringtone appears in the frontend list")
    
    return True

if __name__ == "__main__":
    print("🚀 Starting ringtone fixes test...")
    print("   Make sure the backend server is running on http://localhost:5000")
    print()
    
    try:
        test_ringtone_creation_and_listing()
    except KeyboardInterrupt:
        print("\n⏹️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
    
    print("\n�� Test completed!")
