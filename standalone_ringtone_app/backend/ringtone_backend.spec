# Rules applied
# -*- mode: python ; coding: utf-8 -*-

import os
import sys
from pathlib import Path

# Get the current directory
current_dir = Path(__file__).parent.absolute()

# Define paths
backend_dir = current_dir
project_root = current_dir.parent.parent
original_backend = project_root / 'backend'

# Add the original backend directory to the path for imports
sys.path.insert(0, str(original_backend))

block_cipher = None

# Define data files to include
datas = [
    # Include the original backend Python files
    (str(original_backend / 'server.py'), '.'),
    (str(original_backend / 'taskSchedulerService.py'), '.'),
    (str(original_backend / 'play_ringtone.py'), '.'),
    (str(original_backend / 'play_ringtone.bat'), '.'),
    (str(original_backend / 'play_ringtone.ps1'), '.'),
]

# Define hidden imports
hiddenimports = [
    'flask',
    'flask_cors',
    'pydub',
    'pygame',
    'requests',
    'python_dateutil',
    'winsound',
    'subprocess',
    'json',
    'os',
    'sys',
    'datetime',
    'typing',
    'logging',
    'time',
    'pathlib',
    'uuid',
    'hashlib',
    'shutil',
    'win32com.client',
    'win32api',
    'win32con',
    'pywintypes',
]

a = Analysis(
    ['server.py'],
    pathex=[str(original_backend)],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='ringtone_backend',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
