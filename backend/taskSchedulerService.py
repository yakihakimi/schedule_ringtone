# Rules applied
import subprocess
import json
import os
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class WindowsTaskSchedulerService:
    """
    Service to manage Windows Task Scheduler tasks for ringtone scheduling.
    This service creates, updates, deletes, and manages Windows scheduled tasks.
    """
    
    def __init__(self):
        self.task_folder = ""  # Use root folder instead of custom folder
        self.ringtone_player_script = self._get_ringtone_player_script_path()
        # No need to ensure task folder exists for root folder
    
    def _get_ringtone_player_script_path(self) -> str:
        """Get the path to the ringtone player PowerShell script."""
        script_dir = os.path.dirname(os.path.abspath(__file__))
        return os.path.join(script_dir, "play_ringtone.ps1")
    
    
    def _run_schtasks_command(self, args: List[str]) -> Tuple[bool, str, str]:
        """Run a schtasks command and return success status, stdout, and stderr."""
        try:
            cmd = ["schtasks"] + args
            logger.info(f"🔧 Running command: {' '.join(cmd)}")
            
            result = subprocess.run(
                cmd, 
                capture_output=True, 
                text=True, 
                check=False,
                timeout=30
            )
            
            success = result.returncode == 0
            logger.info(f"📋 Command result - Success: {success}, Return code: {result.returncode}")
            
            if result.stdout:
                logger.info(f"📤 stdout: {result.stdout}")
            if result.stderr:
                logger.info(f"📤 stderr: {result.stderr}")
            
            return success, result.stdout, result.stderr
            
        except subprocess.TimeoutExpired:
            logger.error("❌ Command timed out")
            return False, "", "Command timed out"
        except Exception as e:
            logger.error(f"❌ Error running command: {e}")
            return False, "", str(e)
    
    def _create_ringtone_player_script(self):
        """Create the PowerShell script that will play ringtones."""
        script_content = '''# Rules applied
# PowerShell script to play ringtones via Windows Task Scheduler
param(
    [Parameter(Mandatory=$true)]
    [string]$RingtonePath,
    
    [Parameter(Mandatory=$false)]
    [int]$Volume = 50
)

try {
    # Log the action
    $logFile = Join-Path $env:TEMP "ringtone_scheduler.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - Playing ringtone: $RingtonePath"
    
    # Check if the ringtone file exists
    if (-not (Test-Path $RingtonePath)) {
        Add-Content -Path $logFile -Value "$timestamp - ERROR: Ringtone file not found: $RingtonePath"
        exit 1
    }
    
    # Create WScript.Shell object to play the sound
    $shell = New-Object -ComObject WScript.Shell
    
    # Play the ringtone using Windows Media Player
    $shell.Run("wmplayer.exe /play /close `"$RingtonePath`"", 0, $false)
    
    # Alternative method using PowerShell's built-in sound capabilities
    # This method works for WAV files
    if ($RingtonePath -like "*.wav") {
        Add-Type -AssemblyName System.Windows.Forms
        $sound = [System.Media.SoundPlayer]::new($RingtonePath)
        $sound.PlaySync()
    }
    
    Add-Content -Path $logFile -Value "$timestamp - Successfully played ringtone: $RingtonePath"
    exit 0
    
} catch {
    $errorMsg = $_.Exception.Message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $env:TEMP "ringtone_scheduler.log"
    Add-Content -Path $logFile -Value "$timestamp - ERROR: $errorMsg"
    exit 1
}
'''
        
        try:
            with open(self.ringtone_player_script, 'w', encoding='utf-8') as f:
                f.write(script_content)
            logger.info(f"✅ Created ringtone player script: {self.ringtone_player_script}")
        except Exception as e:
            logger.error(f"❌ Error creating ringtone player script: {e}")
            raise
    
    def create_scheduled_task(self, task_name: str, ringtone_path: str, time: str, days: List[int]) -> bool:
        """
        Create a Windows scheduled task for a ringtone.
        
        Args:
            task_name: Unique name for the task
            ringtone_path: Full path to the ringtone file
            time: Time in HH:MM format
            days: List of days (0=Sunday, 1=Monday, etc.)
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Ensure the ringtone player script exists
            if not os.path.exists(self.ringtone_player_script):
                self._create_ringtone_player_script()
            
            # Convert days to schtasks format
            day_mapping = {
                0: "SUN",  # Sunday
                1: "MON",  # Monday
                2: "TUE",  # Tuesday
                3: "WED",  # Wednesday
                4: "THU",  # Thursday
                5: "FRI",  # Friday
                6: "SAT"   # Saturday
            }
            
            day_list = ",".join([day_mapping[day] for day in days])
            
            # Create the task using batch file wrapper for better window visibility
            batch_script = os.path.join(os.path.dirname(__file__), "play_ringtone.bat")
            args = [
                "/create",
                "/tn", f"Ringtone_{task_name}",
                "/tr", f"\"{batch_script}\" \"{ringtone_path}\"",
                "/sc", "weekly",
                "/d", day_list,
                "/st", time,
                "/f"  # Force creation
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            if success:
                logger.info(f"✅ Created scheduled task: {task_name}")
                return True
            else:
                logger.error(f"❌ Failed to create scheduled task: {task_name}")
                logger.error(f"Error: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error creating scheduled task: {e}")
            return False
    
    def delete_scheduled_task(self, task_name: str) -> bool:
        """
        Delete a Windows scheduled task.
        
        Args:
            task_name: Name of the task to delete
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            args = [
                "/delete",
                "/tn", f"Ringtone_{task_name}",
                "/f"  # Force deletion
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            if success:
                logger.info(f"✅ Deleted scheduled task: {task_name}")
                return True
            else:
                logger.error(f"❌ Failed to delete scheduled task: {task_name}")
                logger.error(f"Error: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error deleting scheduled task: {e}")
            return False
    
    def enable_scheduled_task(self, task_name: str) -> bool:
        """
        Enable a Windows scheduled task.
        
        Args:
            task_name: Name of the task to enable
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            args = [
                "/change",
                "/tn", f"Ringtone_{task_name}",
                "/enable"
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            if success:
                logger.info(f"✅ Enabled scheduled task: {task_name}")
                return True
            else:
                logger.error(f"❌ Failed to enable scheduled task: {task_name}")
                logger.error(f"Error: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error enabling scheduled task: {e}")
            return False
    
    def disable_scheduled_task(self, task_name: str) -> bool:
        """
        Disable a Windows scheduled task.
        
        Args:
            task_name: Name of the task to disable
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            args = [
                "/change",
                "/tn", f"Ringtone_{task_name}",
                "/disable"
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            if success:
                logger.info(f"✅ Disabled scheduled task: {task_name}")
                return True
            else:
                logger.error(f"❌ Failed to disable scheduled task: {task_name}")
                logger.error(f"Error: {stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error disabling scheduled task: {e}")
            return False
    
    def get_task_status(self, task_name: str) -> Optional[str]:
        """
        Get the status of a Windows scheduled task.
        
        Args:
            task_name: Name of the task to check
        
        Returns:
            str: Task status or None if not found
        """
        try:
            args = [
                "/query",
                "/tn", f"Ringtone_{task_name}",
                "/fo", "csv",
                "/v"
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            if success and stdout:
                # Parse the CSV output to find the status
                lines = stdout.strip().split('\n')
                if len(lines) > 1:
                    # Skip header line and get the first data line
                    data_line = lines[1]
                    # The status is typically in one of the columns
                    # This is a simplified parsing - you might need to adjust based on actual output
                    if "Ready" in data_line:
                        return "Ready"
                    elif "Disabled" in data_line:
                        return "Disabled"
                    elif "Running" in data_line:
                        return "Running"
                
            return None
            
        except Exception as e:
            logger.error(f"❌ Error getting task status: {e}")
            return None
    
    def list_all_tasks(self) -> List[Dict]:
        """
        List all ringtone scheduler tasks.
        
        Returns:
            List of task information dictionaries
        """
        try:
            args = [
                "/query",
                "/fo", "csv",
                "/v"
            ]
            
            success, stdout, stderr = self._run_schtasks_command(args)
            
            tasks = []
            if success and stdout:
                lines = stdout.strip().split('\n')
                if len(lines) > 1:
                    # Parse CSV output
                    for line in lines[1:]:  # Skip header
                        if "Ringtone_" in line:
                            # This is one of our tasks
                            parts = line.split(',')
                            if len(parts) > 0:
                                task_name = parts[0].strip('"')
                                # Extract just the task name without the Ringtone_ prefix
                                if "Ringtone_" in task_name:
                                    clean_name = task_name.replace("Ringtone_", "")
                                    tasks.append({
                                        "name": clean_name,
                                        "full_name": task_name,
                                        "status": "Unknown"  # Would need more parsing to get actual status
                                    })
            
            return tasks
            
        except Exception as e:
            logger.error(f"❌ Error listing tasks: {e}")
            return []
    
    def test_ringtone_playback(self, ringtone_path: str) -> bool:
        """
        Test playing a ringtone immediately.
        
        Args:
            ringtone_path: Path to the ringtone file
        
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Use batch file wrapper for better window visibility
            batch_script = os.path.join(os.path.dirname(__file__), "play_ringtone.bat")
            
            # Run the batch script directly
            cmd = [
                batch_script,
                ringtone_path
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                logger.info(f"✅ Successfully tested ringtone: {ringtone_path}")
                return True
            else:
                logger.error(f"❌ Failed to test ringtone: {ringtone_path}")
                logger.error(f"Error: {result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error testing ringtone: {e}")
            return False

# Create singleton instance
task_scheduler_service = WindowsTaskSchedulerService()
