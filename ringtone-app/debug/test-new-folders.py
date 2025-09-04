# Rules applied
# Test script for new folder structure and backend functionality

import os
import sys
import json
from datetime import datetime

# Add the backend directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'backend'))

def test_folder_structure():
    """Test that the new folder structure exists"""
    print("Testing folder structure...")
    
    # Get the project root directory
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    
    # Define expected folders
    expected_folders = [
        os.path.join(project_root, 'ringtones'),
        os.path.join(project_root, 'ringtones', 'wav_ringtones'),
        os.path.join(project_root, 'ringtones', 'mp3_ringtones'),
        os.path.join(project_root, 'original_sound')
    ]
    
    for folder in expected_folders:
        if os.path.exists(folder):
            print(f"✅ {folder} exists")
        else:
            print(f"❌ {folder} does not exist")
            try:
                os.makedirs(folder, exist_ok=True)
                print(f"   Created {folder}")
            except Exception as e:
                print(f"   Failed to create {folder}: {e}")

def test_backend_imports():
    """Test that backend modules can be imported"""
    print("\nTesting backend imports...")
    
    try:
        # Test server imports
        from server import app, RINGTONES_FOLDER, WAV_RINGTONES_FOLDER, MP3_RINGTONES_FOLDER
        print("✅ Server imports successful")
        print(f"   RINGTONES_FOLDER: {RINGTONES_FOLDER}")
        print(f"   WAV_RINGTONES_FOLDER: {WAV_RINGTONES_FOLDER}")
        print(f"   MP3_RINGTONES_FOLDER: {MP3_RINGTONES_FOLDER}")
        
        # Test that folders exist
        if os.path.exists(WAV_RINGTONES_FOLDER):
            print("✅ WAV ringtones folder exists")
        else:
            print("❌ WAV ringtones folder missing")
            
        if os.path.exists(MP3_RINGTONES_FOLDER):
            print("✅ MP3 ringtones folder exists")
        else:
            print("❌ MP3 ringtones folder missing")
            
    except ImportError as e:
        print(f"❌ Import failed: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

def test_api_endpoints():
    """Test that the new API endpoints are properly configured"""
    print("\nTesting API endpoint configuration...")
    
    try:
        from server import app
        
        # Check if the app has the expected routes
        routes = [str(rule) for rule in app.url_map.iter_rules()]
        
        expected_routes = [
            '/api/ringtones',
            '/api/ringtones/<folder>/<filename>'
        ]
        
        for route in expected_routes:
            if any(route in r for r in routes):
                print(f"✅ Route {route} found")
            else:
                print(f"❌ Route {route} not found")
                
        print(f"\nAll available routes:")
        for route in routes:
            if route.startswith('/api/'):
                print(f"   {route}")
                
    except Exception as e:
        print(f"❌ Error testing API endpoints: {e}")

def create_test_files():
    """Create some test files to verify the structure"""
    print("\nCreating test files...")
    
    try:
        project_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
        wav_folder = os.path.join(project_root, 'ringtones', 'wav_ringtones')
        mp3_folder = os.path.join(project_root, 'ringtones', 'mp3_ringtones')
        
        # Create test metadata files
        test_metadata = {
            'id': 'test-123',
            'filename': 'test_ringtone.wav',
            'original_name': 'Test Song',
            'start_time': 10.0,
            'end_time': 30.0,
            'duration': 20.0,
            'created': datetime.now().isoformat(),
            'format': 'wav',
            'folder': 'wav_ringtones'
        }
        
        # Save test metadata
        metadata_path = os.path.join(wav_folder, 'test_metadata.json')
        with open(metadata_path, 'w') as f:
            json.dump(test_metadata, f, indent=2)
        print(f"✅ Created test metadata: {metadata_path}")
        
        # Create a dummy WAV file
        wav_path = os.path.join(wav_folder, 'test_ringtone.wav')
        with open(wav_path, 'w') as f:
            f.write('dummy wav content')
        print(f"✅ Created test WAV file: {wav_path}")
        
        # Create a dummy MP3 file
        mp3_path = os.path.join(mp3_folder, 'test_ringtone.mp3')
        with open(mp3_path, 'w') as f:
            f.write('dummy mp3 content')
        print(f"✅ Created test MP3 file: {mp3_path}")
        
    except Exception as e:
        print(f"❌ Error creating test files: {e}")

if __name__ == "__main__":
    print("🧪 Testing New Folder Structure and Backend Changes")
    print("=" * 60)
    
    test_folder_structure()
    test_backend_imports()
    test_api_endpoints()
    create_test_files()
    
    print("\n🎉 Testing completed!")
    print("\nTo test the full functionality:")
    print("1. Start the backend: python backend/server.py")
    print("2. Start the frontend: npm start")
    print("3. Check the new tab system in the ringtones section")
