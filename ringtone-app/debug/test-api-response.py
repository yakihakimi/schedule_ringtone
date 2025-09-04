# Rules applied
# Test script to check the exact API response structure

import requests
import json

def test_api_response():
    """Test the exact API response structure"""
    
    base_url = "http://localhost:5000"
    
    print("🧪 Testing API Response Structure")
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
    
    # Test 2: Get ringtones list
    print("\n2️⃣ Testing ringtones API response...")
    try:
        response = requests.get(f"{base_url}/api/ringtones")
        
        print(f"📥 Response status: {response.status_code}")
        print(f"📥 Response headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            response_data = response.json()
            print(f"\n✅ SUCCESS! Full response data:")
            print(json.dumps(response_data, indent=2))
            
            # Check specific fields
            print(f"\n🔍 Field Analysis:")
            print(f"   📁 Success: {response_data.get('success')}")
            print(f"   📁 Count: {response_data.get('count')}")
            print(f"   📁 Ringtones: {len(response_data.get('ringtones', []))}")
            
            # Check first ringtone structure
            if response_data.get('ringtones'):
                first_ringtone = response_data['ringtones'][0]
                print(f"\n🔍 First Ringtone Structure:")
                print(f"   📁 ID: {first_ringtone.get('id')}")
                print(f"   📁 Name: {first_ringtone.get('name')}")
                print(f"   📁 Format: {first_ringtone.get('format')}")
                print(f"   📁 Folder: {first_ringtone.get('folder')}")
                print(f"   📁 Has Metadata: {first_ringtone.get('has_metadata')}")
                print(f"   📁 Original Name: {first_ringtone.get('original_name')}")
                print(f"   📁 Start Time: {first_ringtone.get('start_time')}")
                print(f"   📁 End Time: {first_ringtone.get('end_time')}")
                print(f"   📁 Duration: {first_ringtone.get('duration')}")
                
                # Check all ringtones for has_metadata
                print(f"\n🔍 Metadata Status for All Ringtones:")
                for i, rt in enumerate(response_data['ringtones']):
                    print(f"   📁 Ringtone {i+1}: {rt.get('name')} - has_metadata: {rt.get('has_metadata')}")
            else:
                print(f"⚠️ No ringtones in response")
        else:
            print(f"❌ FAILED! Response: {response.text}")
            
    except Exception as e:
        print(f"❌ API test error: {e}")
        return False
    
    print("\n🎯 Test Summary:")
    print("   ✅ Server health check")
    print("   ✅ API response analysis")
    
    return True

if __name__ == "__main__":
    print("🚀 Starting API response structure test...")
    print("   Make sure the backend server is running on http://localhost:5000")
    print()
    
    try:
        test_api_response()
    except KeyboardInterrupt:
        print("\n⏹️ Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
    
    print("\n�� Test completed!")
