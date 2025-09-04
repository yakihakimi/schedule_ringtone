# Windows Task Scheduler Integration

This document describes the Windows Task Scheduler integration for the Schedule Ringtone application.

## Overview

The Schedule Ringtone application now integrates with Windows Task Scheduler to create independent, system-level scheduled tasks. This means:

- **Independent Operation**: Ringtones will play even if the application is closed
- **System-Level Scheduling**: Uses Windows' built-in task scheduler for reliability
- **Automatic Management**: Tasks are automatically created, updated, and deleted when you modify schedules

## How It Works

### 1. Task Creation
When you create a new schedule:
- A Windows scheduled task is created in the "RingtoneScheduler" folder
- The task runs a PowerShell script that plays the ringtone
- The task is scheduled to run at the specified time on selected days

### 2. Task Management
- **Activate/Deactivate**: Enables or disables the Windows task
- **Edit**: Deletes the old task and creates a new one with updated settings
- **Delete**: Removes both the local schedule and the Windows task

### 3. Ringtone Playback
The system uses a PowerShell script (`play_ringtone.ps1`) that:
- Accepts the ringtone file path as a parameter
- Plays the ringtone using Windows Media Player or built-in sound capabilities
- Logs all actions to a log file for debugging

## File Structure

```
backend/
├── taskSchedulerService.py          # Windows Task Scheduler service
├── play_ringtone.ps1               # PowerShell script for playing ringtones
└── server.py                       # Backend server with Task Scheduler endpoints

src/services/
└── scheduleService.ts              # Updated to integrate with Windows Task Scheduler
```

## API Endpoints

The backend provides the following endpoints for Windows Task Scheduler integration:

- `GET /api/task-scheduler/status` - Check if the service is available
- `POST /api/task-scheduler/create` - Create a new scheduled task
- `POST /api/task-scheduler/delete` - Delete a scheduled task
- `POST /api/task-scheduler/enable` - Enable a scheduled task
- `POST /api/task-scheduler/disable` - Disable a scheduled task
- `POST /api/task-scheduler/test` - Test ringtone playback
- `GET /api/task-scheduler/list` - List all scheduled tasks

## Requirements

### System Requirements
- Windows operating system
- PowerShell (included with Windows)
- Windows Task Scheduler service running
- Administrator privileges (may be required for some operations)

### Application Requirements
- Python backend server running
- React frontend application
- Ringtone files accessible to the system

## Usage

### Creating a Schedule
1. Open the Schedule Ringtone application
2. Click "Create New Schedule"
3. Select a ringtone, time, and days
4. Click "Create Schedule"
5. The system will:
   - Create a local schedule record
   - Create a Windows scheduled task
   - Enable the task for immediate use

### Managing Schedules
- **Edit**: Click the "✏️ Edit" button to modify schedule settings
- **Activate/Deactivate**: Click the toggle button to enable/disable the schedule
- **Test**: Click the "🔊 Test" button to play the ringtone immediately
- **Delete**: Click the "🗑️ Delete" button to remove the schedule and task

### Viewing Tasks in Windows Task Scheduler
1. Open Windows Task Scheduler (`taskschd.msc`)
2. Navigate to "Task Scheduler Library" → "RingtoneScheduler"
3. You'll see all your scheduled ringtones as individual tasks
4. You can manually enable/disable tasks here if needed

## Troubleshooting

### Common Issues

1. **"Windows Task Scheduler service is not available"**
   - Ensure the Windows Task Scheduler service is running
   - Check that the backend server is running
   - Verify Python dependencies are installed

2. **"Failed to create scheduled task"**
   - Run the application as administrator
   - Check that the ringtone file exists and is accessible
   - Verify PowerShell execution policy allows script execution

3. **"Ringtone not playing"**
   - Check the log file at `%TEMP%\ringtone_scheduler.log`
   - Verify the ringtone file path is correct
   - Test the ringtone manually using the Test button

### Log Files
- Application logs: Check the browser console and backend server logs
- Task execution logs: `%TEMP%\ringtone_scheduler.log`
- Windows Event Viewer: Look for Task Scheduler events

### Testing
Run the test script to verify the integration:
```bash
python debug/test-windows-task-scheduler.py
```

## Security Considerations

- The PowerShell script runs with the same privileges as the user
- Tasks are created in a dedicated folder to avoid conflicts
- File paths are validated before creating tasks
- All operations are logged for audit purposes

## Future Enhancements

- Support for different audio formats
- Volume control for scheduled ringtones
- Recurring patterns (e.g., every 2 hours)
- Integration with system volume controls
- Backup and restore of scheduled tasks

## Support

If you encounter issues with the Windows Task Scheduler integration:

1. Check the troubleshooting section above
2. Run the test script to identify specific problems
3. Check the log files for error messages
4. Ensure all system requirements are met
5. Try running the application as administrator
