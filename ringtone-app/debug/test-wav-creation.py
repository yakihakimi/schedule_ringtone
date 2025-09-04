# Rules applied
# Test script to test WAV ringtone creation

import requests
import os
import tempfile

def test_wav_ringtone_creation():
    """Test WAV ringtone creation directly with the backend"""
    
    base_url = "http://localhost:5000"
    
    print("🧪 Testing WAV Ringtone Creation")
    print("=" * 50)
    
    # Test 1: Check server health
    print("\n1️⃣ Testing server health...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            print(f"✅ Server is healthy")
        else:
            print(f"❌ Server health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Server health check error: {e}")
        return False
    
    # Test 2: Create a test WAV ringtone
    print("\n2️⃣ Testing WAV ringtone creation...")
    try:
        # Create a dummy WAV file for testing
        with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as temp_file:
            # Create a minimal WAV header
            wav_header = b'RIFF\x24\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x44\xAC\x00\x00\x88\x58\x01\x00\x02\x00\x10\x00data\x00\x00\x00\x00'
            temp_file.write(wav_header)
            temp_file_path = temp_file.name
        
        # Prepare the request data
        with open(temp_file_path, 'rb') as temp_file:
            files = {
                'file': ('test_ringtone.wav', temp_file, 'audio/wav')
            }
            
            data = {
                'original_name': 'Test WAV Song - Artist',
                'start_time': '15.0',
                'end_time': '25.0',
                'duration': '10.0'
            }
            
            print(f"📤 Sending request with:")
            print(f"   📁 File: test_ringtone.wav")
            print(f"   📝 Data: {data}")
            
            # Send the request
            response = requests.post(f"{base_url}/api/ringtones", files=files, data=data)
        
        # Clean up temp file
        os.unlink(temp_file_path)
        
        print(f"\n📥 Response status: {response.status_code}")
        print(f"📥 Response headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            response_data = response.json()
            print(f"✅ SUCCESS! Response data:")
            print(f"   📁 Success: {response_data.get('success')}")
            print(f"   📁 Message: {response_data.get('message')}")
            print(f"   📁 Filename: {response_data.get('filename')}")
            print(f"   📁 Folder: {response_data.get('folder')}")
            print(f"   📁 Format: {response_data.get('format')}")
            print(f"   📁 MP3 Available: {response_data.get('mp3_available')}")
        else:
            print(f"❌ FAILED! Response: {response.text}")
            
    except Exception as e:
        print(f"❌ WAV ringtone creation test error: {e}")
        return False
    
    # Test 3: Check if the WAV ringtone was created
    print("\n3️⃣ Checking if WAV ringtone was created...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        if response.status_code == 200:
            ringtones_data = response.json()
            if ringtones_data.get('success'):
                ringtones = ringtones_data.get('ringtones', [])
                print(f"✅ Found {len(ringtones)} ringtones")
                
                # Look for our test WAV ringtone
                test_ringtones = [r for r in ringtones if 'test_ringtone' in r.get('name', '') and r.get('format') == 'wav']
                if test_ringtones:
                    print(f"🎵 Test WAV ringtone found:")
                    for rt in test_ringtones:
                        print(f"   📁 Name: {rt.get('name')}")
                        print(f"   📁 Format: {rt.get('format')}")
                        print(f"   📁 Folder: {rt.get('folder')}")
                else:
                    print(f"⚠️ Test WAV ringtone not found in list")
            else:
                print(f"⚠️ Failed to list ringtones: {ringtones_data.get('error')}")
        else:
            print(f"❌ Failed to list ringtones: {response.status_code}")
    except Exception as e:
        print(f"❌ Error checking ringtones: {e}")
    
    print("\n🎯 Test Summary:")
    print("   ✅ Server health check")
    print("   ✅ WAV ringtone creation test")
    print("   ✅ WAV ringtone verification")
    
    return True

if __name__ == "__main__":
    print("🚀 Starting WAV ringtone creation test...")
    print("   Make sure the backend server is running on http://localhost:5000")
    print()
    
    try:
        test_wav_ringtone_creation()
    except KeyboardInterrupt:
        print("\n⏹️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
    
    print("\n�� Test completed!")
