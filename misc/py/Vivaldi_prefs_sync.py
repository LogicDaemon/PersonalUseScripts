#!/usr/bin/env python
import logging
import logging.handlers
import os
import platform
from pathlib import Path

import psutil

from lib.get_dropbox_dir import get_dropbox_dir
from lib.json_sync import sync_json_changes

log = logging.getLogger(
    Path(__file__).stem if __name__ == '__main__' else __name__)
LocalAppData = Path(os.getenv('LOCALAPPDATA'))  # type: ignore


def link_or_copy_settings_to_dropbox(dest_base: Path) -> list[Path]:
    files_to_copy = [
        'Bookmarks', 'Calendar', 'Contacts', 'contextmenu.json',
        'Custom Dictionary.txt', 'Notes', 'Preferences', 'Secure Preferences',
        'Shortcuts', 'Web Data'
    ]

    skip_profiles = {"System Profile", "Guest Profile"}

    found_profiles = []
    for p in (LocalAppData / 'Vivaldi' / 'User Data').iterdir():
        if not p.is_dir() or p.name in skip_profiles:
            continue
        if not (p / 'Preferences').exists():
            continue
        found_profiles.append(p)
        dest_subdir = dest_base / p.name
        dest_subdir.mkdir(parents=True, exist_ok=True)
        for fname in files_to_copy:
            rel_path = p / fname
            if not rel_path.exists():
                continue
            dest = dest_subdir / fname
            if dest.samefile(rel_path):
                continue
            tmp_path = dest_subdir / (fname + '.tmp')
            try:
                tmp_path.hardlink_to(rel_path)
            except OSError:
                log.warning(
                    'Hardlink failed for %s; copying instead',
                    rel_path,
                    exc_info=True)
                rel_path.copy(tmp_path)
            try:
                tmp_path.replace(dest)
            except OSError:
                log.error(
                    'Failed to move %s to %s', tmp_path, dest, exc_info=True)

    return found_profiles


def main() -> None:
    logging.basicConfig(
        level=logging.DEBUG if os.getenv('DEBUG') else logging.INFO)
    configs_dir = get_dropbox_dir(False) / 'Config'
    perhost_dir = configs_dir / f'@{platform.node()}'
    logging.root.addHandler(
        logging.handlers.RotatingFileHandler(
            perhost_dir / 'json-sync.log', maxBytes=1024 * 1024, backupCount=2))
    profiles = link_or_copy_settings_to_dropbox(perhost_dir / 'Vivaldi' /
                                                'User Data')

    # if any(proc.info['name'] == 'vivaldi.exe'
    #        for proc in psutil.process_iter(['name'])):
    #     raise RuntimeError(
    #         'Vivaldi is running; please close it before running this script.')

    group_name = (perhost_dir / '#group.txt').read_text().strip()
    group_dir = configs_dir / f'#{group_name}' / 'Vivaldi'

    prev_version_dir = perhost_dir / 'Vivaldi' / 'sync_base'
    prev_version_dir.mkdir(parents=True, exist_ok=True)
    sync_json_changes(
        [p / 'Preferences' for p in profiles] + [group_dir / 'Preferences'],
        group_dir / 'Preferences-sync-filter.json', prev_version_dir)


if __name__ == "__main__":
    main()
