# Rules applied
#!/usr/bin/env python3
"""
Script to install FFmpeg in the working directory for portable installation
"""

import os
import sys
import zipfile
import urllib.request
import shutil
from pathlib import Path

def download_file(url, destination):
    """Download a file from URL to destination"""
    try:
        print(f"🌐 Downloading from: {url}")
        urllib.request.urlretrieve(url, destination)
        print("✅ Download completed")
        return True
    except Exception as e:
        print(f"❌ Download failed: {e}")
        return False

def extract_zip(zip_path, extract_to):
    """Extract zip file to destination"""
    try:
        print(f"📦 Extracting {zip_path} to {extract_to}")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_to)
        print("✅ Extraction completed")
        return True
    except Exception as e:
        print(f"❌ Extraction failed: {e}")
        return False

def install_ffmpeg_portable():
    """Install FFmpeg in the working directory"""
    print("🔧 Installing FFmpeg in working directory for portable installation...")
    print("")
    
    # Get the project root directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    ffmpeg_dir = project_root / "ffmpeg"
    ffmpeg_bin_dir = ffmpeg_dir / "bin"
    
    print(f"📁 Project root: {project_root}")
    print(f"📁 FFmpeg directory: {ffmpeg_dir}")
    print(f"📁 FFmpeg bin directory: {ffmpeg_bin_dir}")
    print("")
    
    # Check if ffmpeg is already installed
    ffmpeg_exe = ffmpeg_bin_dir / "ffmpeg.exe"
    if ffmpeg_exe.exists():
        print("✅ FFmpeg is already installed in working directory!")
        print(f"📁 Location: {ffmpeg_bin_dir}")
        
        # Test the installation
        try:
            import subprocess
            result = subprocess.run([str(ffmpeg_exe), "-version"], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                version_line = result.stdout.split('\n')[0]
                print(f"🔍 Version: {version_line}")
                print("")
                print("💡 The backend should now be able to find FFmpeg automatically")
                return True
            else:
                print("⚠️ FFmpeg found but may not be working properly")
        except Exception as e:
            print(f"⚠️ Error testing FFmpeg: {e}")
    
    print("📥 Downloading FFmpeg for portable installation...")
    
    # Create ffmpeg directory
    ffmpeg_dir.mkdir(exist_ok=True)
    print(f"📁 Created directory: {ffmpeg_dir}")
    
    # Download FFmpeg
    download_url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    zip_file = ffmpeg_dir / "ffmpeg.zip"
    extract_dir = ffmpeg_dir / "temp"
    
    try:
        # Download
        if not download_file(download_url, zip_file):
            return False
        
        # Extract
        if not extract_zip(zip_file, extract_dir):
            return False
        
        # Find the extracted folder
        extracted_folders = [f for f in extract_dir.iterdir() if f.is_dir()]
        if not extracted_folders:
            print("❌ Could not find extracted FFmpeg directory")
            return False
        
        source_dir = extracted_folders[0]
        source_bin_dir = source_dir / "bin"
        
        if not source_bin_dir.exists():
            print("❌ Could not find bin directory in extracted files")
            return False
        
        # Copy bin directory to our target location
        if ffmpeg_bin_dir.exists():
            shutil.rmtree(ffmpeg_bin_dir)
        shutil.copytree(source_bin_dir, ffmpeg_bin_dir)
        print(f"✅ FFmpeg extracted to: {ffmpeg_bin_dir}")
        
        # Clean up
        shutil.rmtree(extract_dir)
        zip_file.unlink()
        
        # Test the installation
        try:
            import subprocess
            result = subprocess.run([str(ffmpeg_exe), "-version"], 
                                  capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                version_line = result.stdout.split('\n')[0]
                print(f"🔍 Version: {version_line}")
                print("")
                print("🎉 FFmpeg installed successfully in working directory!")
                print(f"📁 Location: {ffmpeg_bin_dir}")
                print("")
                print("💡 The backend will now automatically find FFmpeg")
                print("💡 No system PATH changes required")
                return True
            else:
                print("❌ FFmpeg installation failed - executable not working")
                return False
                
        except Exception as e:
            print(f"❌ Error testing FFmpeg: {e}")
            return False
        
    except Exception as e:
        print(f"❌ Installation failed: {e}")
        print("")
        print("📋 Manual Installation Instructions:")
        print("1. Download FFmpeg from: https://ffmpeg.org/download.html")
        print(f"2. Extract to: {ffmpeg_dir}")
        print("3. Ensure the bin folder contains ffmpeg.exe")
        print("4. The backend will automatically detect it")
        return False

if __name__ == "__main__":
    success = install_ffmpeg_portable()
    if not success:
        sys.exit(1)
    
    print("")
    input("Press Enter to continue...")

