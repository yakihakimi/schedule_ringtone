# Rules applied
import os

def test_paths():
    """Test the folder paths to ensure they're correct"""
    print("🧪 Testing Ringtone Creator Folder Paths")
    print("=" * 50)
    
    # Get the current directory (should be ringtone-app/debug)
    current_dir = os.getcwd()
    print(f"Current directory: {current_dir}")
    
    # Go up to ringtone-app directory
    ringtone_app_dir = os.path.dirname(os.path.dirname(current_dir))
    print(f"Ringtone app directory: {ringtone_app_dir}")
    
    # Go up to the main project directory
    project_dir = os.path.dirname(ringtone_app_dir)
    print(f"Project directory: {project_dir}")
    
    # Test the old path (3 levels up)
    old_ringtones_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(current_dir))), 'ringtones')
    print(f"Old ringtones path (3 levels up): {old_ringtones_path}")
    print(f"Old ringtones path exists: {os.path.exists(old_ringtones_path)}")
    
    # Test the new path (2 levels up)
    new_ringtones_path = os.path.join(os.path.dirname(os.path.dirname(current_dir)), 'ringtones')
    print(f"New ringtones path (2 levels up): {new_ringtones_path}")
    print(f"New ringtones path exists: {os.path.exists(new_ringtones_path)}")
    
    # Test the correct path (should be C:\devops\‏‏ringbreak-react\ringtones)
    correct_ringtones_path = os.path.join(project_dir, 'ringtones')
    print(f"Correct ringtones path: {correct_ringtones_path}")
    print(f"Correct ringtones path exists: {os.path.exists(correct_ringtones_path)}")
    
    # Create the ringtones directory if it doesn't exist
    if not os.path.exists(correct_ringtones_path):
        os.makedirs(correct_ringtones_path, exist_ok=True)
        print(f"✅ Created ringtones directory: {correct_ringtones_path}")
    else:
        print(f"✅ Ringtones directory already exists: {correct_ringtones_path}")
    
    # List contents of the ringtones directory
    if os.path.exists(correct_ringtones_path):
        contents = os.listdir(correct_ringtones_path)
        print(f"Contents of ringtones directory: {contents}")
    
    print("\n" + "=" * 50)
    print("🎉 Path testing completed!")
    
    return correct_ringtones_path

if __name__ == "__main__":
    test_paths()
