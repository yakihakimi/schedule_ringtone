# Rules applied
import os
import json
from datetime import datetime

def test_file_creation():
    """Test creating files in the ringtones folder"""
    print("🧪 Testing File Creation in Ringtones Folder")
    print("=" * 50)
    
    # Calculate the correct paths (same as backend)
    backend_dir = os.path.dirname(os.path.dirname(__file__))
    ringtones_folder = os.path.join(backend_dir, '..', 'ringtones')
    original_sound_folder = os.path.join(backend_dir, '..', 'original_sound')
    
    # Get absolute paths
    ringtones_abs = os.path.abspath(ringtones_folder)
    original_sound_abs = os.path.abspath(original_sound_folder)
    
    print(f"Ringtones folder: {ringtones_abs}")
    print(f"Original sound folder: {original_sound_abs}")
    
    # Ensure directories exist
    os.makedirs(ringtones_folder, exist_ok=True)
    os.makedirs(original_sound_folder, exist_ok=True)
    
    print(f"✅ Directories created/verified")
    
    # Create a test file
    test_filename = f"test_ringtone_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    test_file_path = os.path.join(ringtones_folder, test_filename)
    
    # Write test content
    test_content = f"This is a test ringtone file created at {datetime.now().isoformat()}"
    with open(test_file_path, 'w') as f:
        f.write(test_content)
    
    print(f"✅ Test file created: {test_filename}")
    print(f"   Full path: {os.path.abspath(test_file_path)}")
    
    # Create test metadata
    metadata = {
        'id': 'test-123',
        'filename': test_filename,
        'original_name': 'Test Song',
        'start_time': 10.0,
        'end_time': 30.0,
        'duration': 20.0,
        'created': datetime.now().isoformat()
    }
    
    metadata_filename = test_filename.rsplit('.', 1)[0] + '.json'
    metadata_path = os.path.join(ringtones_folder, metadata_filename)
    
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"✅ Test metadata created: {metadata_filename}")
    
    # List contents of ringtones folder
    contents = os.listdir(ringtones_folder)
    print(f"📁 Contents of ringtones folder: {contents}")
    
    # Verify files exist
    for filename in contents:
        file_path = os.path.join(ringtones_folder, filename)
        file_size = os.path.getsize(file_path)
        print(f"   - {filename} ({file_size} bytes)")
    
    print("\n" + "=" * 50)
    print("🎉 File creation test completed!")
    print(f"Files are now in: {ringtones_abs}")
    
    return test_file_path

if __name__ == "__main__":
    test_file_creation()
