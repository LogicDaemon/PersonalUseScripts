import os
import json
from pathlib import Path
import subprocess
import time
import psutil


def get_dropbox_dir(start_dropbox_if_not_running: bool = True) -> Path:
    local_app_data = Path(os.getenv('LOCALAPPDATA'))  # type: ignore
    assert local_app_data is not None, 'LOCALAPPDATA environment variable not found'

    if start_dropbox_if_not_running:
        while not any(proc.info['name'] == 'dropbox.exe'
                      for proc in psutil.process_iter(['name'])):
            subprocess.check_call(local_app_data / 'Scripts' / 'Dropbox.ahk')
            time.sleep(10)

    with (local_app_data / 'Dropbox' / 'info.json').open('rb') as f:
        dropbox_info = json.load(f)
    return Path(dropbox_info['personal']['path'])
