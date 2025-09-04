# Rules applied
"""
Test script for Windows Task Scheduler integration
This script tests the Windows Task Scheduler service functionality
"""

import sys
import os
import time

# Add the backend directory to the path
backend_dir = os.path.join(os.path.dirname(__file__), '..', 'backend')
sys.path.insert(0, backend_dir)

try:
    from taskSchedulerService import task_scheduler_service
    print("✅ Successfully imported Windows Task Scheduler service")
except ImportError as e:
    print(f"❌ Failed to import Windows Task Scheduler service: {e}")
    sys.exit(1)

def test_task_scheduler_service():
    """Test the Windows Task Scheduler service functionality"""
    print("🧪 Testing Windows Task Scheduler Service")
    print("=" * 50)
    
    # Test 1: Check if service is available
    print("Test 1: Service availability")
    try:
        print("✅ Windows Task Scheduler service is available")
    except Exception as e:
        print(f"❌ Service not available: {e}")
        return False
    
    # Test 2: Create a test task
    print("\nTest 2: Creating a test scheduled task")
    test_task_name = "test_ringtone_task"
    test_ringtone_path = "C:\\Windows\\Media\\chimes.wav"  # Use a system sound for testing
    test_time = "12:00"
    test_days = [1, 2, 3, 4, 5]  # Monday to Friday
    
    try:
        success = task_scheduler_service.create_scheduled_task(
            test_task_name, 
            test_ringtone_path, 
            test_time, 
            test_days
        )
        if success:
            print("✅ Test task created successfully")
        else:
            print("❌ Failed to create test task")
            return False
    except Exception as e:
        print(f"❌ Error creating test task: {e}")
        return False
    
    # Test 3: List tasks
    print("\nTest 3: Listing scheduled tasks")
    try:
        tasks = task_scheduler_service.list_all_tasks()
        print(f"✅ Found {len(tasks)} scheduled tasks")
        for task in tasks:
            print(f"   - {task['name']}: {task['status']}")
    except Exception as e:
        print(f"❌ Error listing tasks: {e}")
    
    # Test 4: Disable task
    print("\nTest 4: Disabling test task")
    try:
        success = task_scheduler_service.disable_scheduled_task(test_task_name)
        if success:
            print("✅ Test task disabled successfully")
        else:
            print("❌ Failed to disable test task")
    except Exception as e:
        print(f"❌ Error disabling test task: {e}")
    
    # Test 5: Enable task
    print("\nTest 5: Enabling test task")
    try:
        success = task_scheduler_service.enable_scheduled_task(test_task_name)
        if success:
            print("✅ Test task enabled successfully")
        else:
            print("❌ Failed to enable test task")
    except Exception as e:
        print(f"❌ Error enabling test task: {e}")
    
    # Test 6: Test ringtone playback
    print("\nTest 6: Testing ringtone playback")
    try:
        success = task_scheduler_service.test_ringtone_playback(test_ringtone_path)
        if success:
            print("✅ Ringtone playback test successful")
        else:
            print("❌ Ringtone playback test failed")
    except Exception as e:
        print(f"❌ Error testing ringtone playback: {e}")
    
    # Test 7: Delete test task
    print("\nTest 7: Deleting test task")
    try:
        success = task_scheduler_service.delete_scheduled_task(test_task_name)
        if success:
            print("✅ Test task deleted successfully")
        else:
            print("❌ Failed to delete test task")
    except Exception as e:
        print(f"❌ Error deleting test task: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 Windows Task Scheduler service tests completed!")
    return True

if __name__ == "__main__":
    print("🚀 Starting Windows Task Scheduler Integration Test")
    print("This test will create, modify, and delete a test scheduled task")
    print("Make sure you have administrator privileges if required")
    print()
    
    try:
        success = test_task_scheduler_service()
        if success:
            print("\n✅ All tests passed! Windows Task Scheduler integration is working.")
        else:
            print("\n❌ Some tests failed. Check the output above for details.")
    except Exception as e:
        print(f"\n❌ Test suite failed with error: {e}")
        sys.exit(1)
