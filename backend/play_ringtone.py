#!/usr/bin/env python3
"""
Python script to play ringtone files using pygame or system audio.
This script is called by Windows Task Scheduler to play scheduled ringtones.
"""

import sys
import os
import time
import logging
from pathlib import Path

# Set up logging with proper file location

# Create log file in a safe location
log_dir = os.path.dirname(os.path.abspath(__file__))
log_file = os.path.join(log_dir, 'ringtone_playback.log')

# Try to set up file logging, fall back to console only if it fails
try:
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file, mode='a'),
            logging.StreamHandler()
        ]
    )
except PermissionError:
    # Fall back to console-only logging if file logging fails
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[logging.StreamHandler()]
    )
logger = logging.getLogger(__name__)

def play_ringtone_with_pygame(ringtone_path):
    """Play ringtone using pygame (preferred method)"""
    try:
        import pygame
        pygame.mixer.init()
        pygame.mixer.music.load(ringtone_path)
        pygame.mixer.music.play()
        
        # Wait for the music to finish playing
        while pygame.mixer.music.get_busy():
            time.sleep(0.1)
            
        pygame.mixer.quit()
        logger.info(f"Successfully played ringtone with pygame: {ringtone_path}")
        return True
        
    except ImportError:
        logger.warning("pygame not available, trying alternative method")
        return False
    except Exception as e:
        logger.error(f"Error playing ringtone with pygame: {e}")
        return False

def play_ringtone_with_winsound(ringtone_path):
    """Play ringtone using winsound (Windows only, WAV files only)"""
    try:
        import winsound
        
        # Check if file is WAV
        if not ringtone_path.lower().endswith('.wav'):
            logger.warning("⚠️ winsound only supports WAV files")
            return False
            
        # Play the sound
        winsound.PlaySound(ringtone_path, winsound.SND_FILENAME | winsound.SND_ASYNC)
        
        # Wait a bit for the sound to start
        time.sleep(0.5)
        
        logger.info(f"Successfully played ringtone with winsound: {ringtone_path}")
        return True
        
    except ImportError:
        logger.warning("winsound not available")
        return False
    except Exception as e:
        logger.error(f"Error playing ringtone with winsound: {e}")
        return False

def play_ringtone_with_system(ringtone_path):
    """Play ringtone using system command (fallback method)"""
    try:
        import subprocess
        
        # Try different system commands based on OS
        if os.name == 'nt':  # Windows
            # Use Windows Media Player
            cmd = ['wmplayer', '/play', '/close', ringtone_path]
        else:  # Linux/Mac
            # Try common audio players
            for player in ['aplay', 'paplay', 'afplay']:
                try:
                    subprocess.run([player, ringtone_path], check=True, timeout=30)
                    logger.info(f"Successfully played ringtone with {player}: {ringtone_path}")
                    return True
                except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
                    continue
                    
        logger.warning("No suitable system audio player found")
        return False
        
    except Exception as e:
        logger.error(f"Error playing ringtone with system command: {e}")
        return False

def main():
    """Main function to play ringtone"""
    # Add 5-second delay for debugging - so you can see the output window
    logger.info("=" * 60)
    logger.info("RINGTONE PLAYBACK SCRIPT STARTED")
    logger.info("=" * 60)
    logger.info("Waiting 5 seconds for debugging purposes...")
    time.sleep(5)
    
    if len(sys.argv) != 2:
        logger.error("Usage: python play_ringtone.py <ringtone_path>")
        sys.exit(1)
    
    ringtone_path = sys.argv[1]
    
    # Validate file exists
    if not os.path.exists(ringtone_path):
        logger.error(f"Ringtone file not found: {ringtone_path}")
        sys.exit(1)
    
    logger.info(f"Attempting to play ringtone: {ringtone_path}")
    logger.info(f"File size: {os.path.getsize(ringtone_path)} bytes")
    logger.info(f"File extension: {os.path.splitext(ringtone_path)[1]}")
    
    # Try different methods in order of preference
    methods = [
        ("pygame", play_ringtone_with_pygame),
        ("winsound", play_ringtone_with_winsound),
        ("system", play_ringtone_with_system)
    ]
    
    for method_name, method_func in methods:
        logger.info(f"Trying {method_name} method...")
        if method_func(ringtone_path):
            logger.info(f"Successfully played ringtone using {method_name}")
            logger.info("Press any key to close this window...")
            input()  # Wait for user input before closing
            sys.exit(0)
    
    # If all methods failed
    logger.error("All playback methods failed")
    logger.info("Press any key to close this window...")
    input()  # Wait for user input before closing
    sys.exit(1)

if __name__ == "__main__":
    main()
