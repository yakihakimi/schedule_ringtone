# Rules applied
import requests
import json
import os

def test_backend():
    """Test the backend API endpoints"""
    base_url = "http://localhost:5000"
    
    print("🧪 Testing Ringtone Creator Backend API")
    print("=" * 50)
    
    # Test 1: Health check
    print("\n1. Testing health check...")
    try:
        response = requests.get(f"{base_url}/health")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health check passed: {data['status']}")
            print(f"   Ringtones folder: {data['ringtones_folder']}")
            print(f"   Upload folder: {data['upload_folder']}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend server")
        print("   Make sure the backend is running on http://localhost:5000")
        return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False
    
    # Test 2: List ringtones
    print("\n2. Testing list ringtones...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ List ringtones: {data['count']} ringtones found")
            for ringtone in data['ringtones']:
                print(f"   - {ringtone['name']} ({ringtone['size']} bytes)")
        else:
            print(f"❌ List ringtones failed: {response.status_code}")
    except Exception as e:
        print(f"❌ List ringtones error: {e}")
    
    # Test 3: Test CORS headers
    print("\n3. Testing CORS headers...")
    try:
        response = requests.options(f"{base_url}/api/ringtones")
        cors_headers = response.headers.get('Access-Control-Allow-Origin')
        if cors_headers:
            print(f"✅ CORS enabled: {cors_headers}")
        else:
            print("⚠️  CORS headers not found")
    except Exception as e:
        print(f"❌ CORS test error: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Backend API test completed!")
    print("\nTo start the backend server:")
    print("   Windows: start_backend.bat or start_backend.ps1")
    print("   Manual: cd backend && python server.py")
    
    return True

if __name__ == "__main__":
    test_backend()
