# Rules applied
# Test script to verify MP3 conversion functionality

import requests
import json
import os

def test_mp3_conversion():
    """Test the MP3 conversion functionality"""
    print("🧪 Testing MP3 Conversion Functionality")
    print("=" * 50)
    
    # Test the health endpoint
    try:
        response = requests.get('http://localhost:5000/health')
        if response.status_code == 200:
            health_data = response.json()
            print("✅ Backend is healthy")
            print(f"📁 WAV ringtones folder: {health_data.get('wav_ringtones_folder')}")
            print(f"📁 MP3 ringtones folder: {health_data.get('mp3_ringtones_folder')}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Cannot connect to backend: {e}")
        return
    
    # Test listing ringtones
    try:
        response = requests.get('http://localhost:5000/api/ringtones')
        if response.status_code == 200:
            ringtone_data = response.json()
            ringtones = ringtone_data.get('ringtones', [])
            print(f"\n📱 Found {len(ringtones)} ringtones:")
            
            for ringtone in ringtones:
                print(f"  • {ringtone.get('name', 'Unknown')}")
                print(f"    Format: {ringtone.get('format', 'Unknown').upper()}")
                print(f"    Folder: {ringtone.get('folder', 'Unknown')}")
                print(f"    MP3 Available: {ringtone.get('mp3_available', False)}")
                if ringtone.get('mp3_filename'):
                    print(f"    MP3 Filename: {ringtone.get('mp3_filename')}")
                print()
        else:
            print(f"❌ Failed to list ringtones: {response.status_code}")
    except Exception as e:
        print(f"❌ Error listing ringtones: {e}")
    
    # Check if MP3 files exist in the mp3_ringtones folder
    mp3_folder = os.path.join(os.path.dirname(os.path.dirname(__file__)), '..', 'ringtones', 'mp3_ringtones')
    if os.path.exists(mp3_folder):
        mp3_files = [f for f in os.listdir(mp3_folder) if f.endswith('.mp3')]
        print(f"📁 MP3 ringtones folder contains {len(mp3_files)} MP3 files:")
        for mp3_file in mp3_files:
            print(f"  • {mp3_file}")
    else:
        print("📁 MP3 ringtones folder does not exist")
    
    print("\n" + "=" * 50)
    print("🎯 To test MP3 conversion:")
    print("1. Create a new ringtone through the frontend")
    print("2. Check that both WAV and MP3 versions are created")
    print("3. Verify both formats show 'Format: WAV' and 'Format: MP3'")

if __name__ == '__main__':
    test_mp3_conversion()
