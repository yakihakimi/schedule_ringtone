# Uninstall Scripts

This folder contains batch files to uninstall Node.js and FFmpeg from your Windows system.

## Available Scripts

### `uninstall_all.bat`
Master uninstaller that runs both Node.js and FFmpeg uninstallers in sequence.
- **Recommended for complete removal**
- Includes confirmation prompts
- Provides summary of actions taken

### `uninstall_nodejs.bat`
Removes Node.js and npm from your system:
- Stops running Node.js processes
- Removes installation directories
- Cleans up npm cache and global packages
- Removes registry entries
- Updates system PATH

### `uninstall_ffmpeg.bat`
Removes FFmpeg from your system:
- Stops running FFmpeg processes
- Removes installation directories (including portable version in project)
- Cleans up temporary files
- Removes registry entries
- Updates system PATH

## Usage

1. **Run as Administrator** (recommended for complete removal)
2. Double-click the desired batch file
3. Follow the on-screen prompts
4. Restart your computer after completion

## Important Notes

- Always run these scripts as Administrator for complete removal
- Some files may require manual deletion if not running as Administrator
- Restart your computer after uninstallation to ensure environment variables are updated
- Check for any remaining shortcuts or configuration files manually

## Troubleshooting

If you encounter issues:
1. Run individual uninstallers separately
2. Check for remaining folders in Program Files
3. Verify PATH environment variable is clean
4. Look for any remaining registry entries
5. Check for desktop/start menu shortcuts

## Safety

These scripts are designed to be safe and include:
- Confirmation prompts before deletion
- Process termination before file removal
- Error handling and warnings
- Detailed logging of actions taken
