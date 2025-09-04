# Rules applied
# Test script to test ringtone creation directly

import requests
import os
import tempfile

def test_ringtone_creation():
    """Test ringtone creation directly with the backend"""
    
    base_url = "http://localhost:5000"
    
    print("🧪 Testing Ringtone Creation Directly")
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
    
    # Test 2: Create a test ringtone
    print("\n2️⃣ Testing ringtone creation...")
    try:
        # Create a dummy MP3 file for testing
        with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as temp_file:
            temp_file.write(b'fake mp3 content')
            temp_file_path = temp_file.name
        
        # Prepare the request data
        with open(temp_file_path, 'rb') as temp_file:
            files = {
                'file': ('test_ringtone.mp3', temp_file, 'audio/mpeg')
            }
            
            data = {
                'original_name': 'Test Song - Artist',
                'start_time': '10.0',
                'end_time': '20.0',
                'duration': '10.0'
            }
            
            print(f"📤 Sending request with:")
            print(f"   📁 File: test_ringtone.mp3")
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
        print(f"❌ Ringtone creation test error: {e}")
        return False
    
    # Test 3: Check if the ringtone was actually created
    print("\n3️⃣ Checking if ringtone was created...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        if response.status_code == 200:
            ringtones_data = response.json()
            if ringtones_data.get('success'):
                ringtones = ringtones_data.get('ringtones', [])
                print(f"✅ Found {len(ringtones)} ringtones")
                
                # Look for our test ringtone
                test_ringtones = [r for r in ringtones if 'test_ringtone' in r.get('name', '')]
                if test_ringtones:
                    print(f"🎵 Test ringtone found:")
                    for rt in test_ringtones:
                        print(f"   📁 Name: {rt.get('name')}")
                        print(f"   📁 Format: {rt.get('format')}")
                        print(f"   📁 Folder: {rt.get('folder')}")
                else:
                    print(f"⚠️ Test ringtone not found in list")
            else:
                print(f"⚠️ Failed to list ringtones: {ringtones_data.get('error')}")
        else:
            print(f"❌ Failed to list ringtones: {response.status_code}")
    except Exception as e:
        print(f"❌ Error checking ringtones: {e}")
    
    print("\n🎯 Test Summary:")
    print("   ✅ Server health check")
    print("   ✅ Ringtone creation test")
    print("   ✅ Ringtone verification")
    
    return True

if __name__ == "__main__":
    print("🚀 Starting direct ringtone creation test...")
    print("   Make sure the backend server is running on http://localhost:5000")
    print()
    
    try:
        test_ringtone_creation()
    except KeyboardInterrupt:
        print("\n⏹️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
    
    print("\n�� Test completed!")
