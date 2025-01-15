#!/usr/bin/env python3
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import json
import os
import sys
import winreg
import win32file
from pathlib import Path
from typing import Dict, Optional, Union

import _winapi

# if os.name == 'nt':
#     import pywin32


def get_hostname() -> str:
    """ Return the hostname """
    if os.name == 'posix':
        return os.uname().nodename  # pylint: disable=no-member
    # assume it's Windows
    with winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters') as key:
        return winreg.QueryValueEx(key, 'Hostname')[0]


def get_dropbox_dir() -> Path:
    """ Return the Dropbox directory """
    info_json_path = (
        os.environ['LOCALAPPDATA'] +
        r'\Dropbox\info.json' if os.name == 'nt' else os.environ['HOME'] +
        '/.dropbox/info.json')
    with open(info_json_path) as f:
        data = json.load(f)
        return Path(data['personal']['path'])


def get_group_configs_dir(configs_base_dir: Path,
                          host_configs_dir: Path) -> Path:
    """ Return the group configuration directory """
    with open(host_configs_dir / '#group.txt') as f:
        group = f.read().strip()
    return configs_base_dir / f'#{group}'


def read_descript_ion(base_dir: Path) -> Dict[str, str]:
    """ Read the descript.ion file in the given directory
        and return a dictionary with the file names as keys
        and the descriptions as values
    """
    data = {}
    with (base_dir / 'descript.ion').open() as f:
        for line in f:
            if line.startswith(';'):
                continue
            if line.startswith('"'):
                filename_end_pos = line.find('"', 1)
                filename = line[1:filename_end_pos]
                description = (line[filename_end_pos + 2:]
                              )  # +2 for the space and the quote
                description = description.strip().replace(r'\n', '\n')
            else:
                filename, description = line.split(maxsplit=1)
            data[filename] = description
    return data


def get_path_from_description(description: str) -> Optional[Path]:
    """ Return the path from the description """
    if '\n' in description:
        for line in description.splitlines():
            p = get_path_from_description(line)
            if p is not None:
                return p
    p = Path(description)
    if p.is_absolute():
        return p
    return None


def log_error(action: str,
              *details: str,
              exception: Union[None, bool, BaseException] = True) -> None:
    """ Log an error """
    print('Failed to', action, *details, file=sys.stderr)
    if not exception:
        return
    if exception is True:
        e = sys.exc_info()
        exception = e[1] if isinstance(e, tuple) else e
    print(repr(exception), file=sys.stderr)


def mk_symlink(src: Path, dest: Path) -> bool:
    """ Create a symbolic link """
    try:
        src.symlink_to(dest)
    except OSError:
        log_error('create a symlink', f'"{src}"', 'to', f'"{dest}"')
        return False
    return True


def mk_junction(src: Path, dest: Path) -> bool:
    """ Create a junction """
    try:
        _winapi.CreateJunction(str(src), str(dest))
    except OSError:
        log_error('create a junction', f'"{src}"', 'to', f'"{dest}"')
        return False
    return True


def link_configs(configs_dir: Path) -> None:
    """ Link the configuration files in the given config directory """
    for name, descr in read_descript_ion(configs_dir).items():
        src = get_path_from_description(descr)
        if src is None or src.is_junction() or src.is_symlink():
            continue
        tmp_src = src.with_suffix(src.suffix + '.tmp')
        dst = configs_dir / name
        if src.is_dir():
            if next(src.iterdir(), None) is None:
                src.rmdir()
            else:
                if dst.exists():
                    print(
                        '"',
                        src,
                        '" is a non-empty directory, and "',
                        dst,
                        '" already exists.',
                        file=sys.stderr)
                    continue
                src.rename(tmp_src)
                if mk_symlink(src, dst) or mk_junction(src, dst):
                    tmp_src.rename(dst)
                else:
                    tmp_src.rename(src)
                continue

        if src.exists():
            if dst.exists():
                print(
                    '"',
                    src,
                    '" exists and "',
                    dst,
                    '" exists too.',
                    file=sys.stderr)
                continue
            src.rename(dst)
            mk_symlink(src, dst)
            continue

        # src does not exist
        if not dst.exists():
            continue

        mk_symlink(src, dst) or (dst.is_dir() and mk_junction(src, dst))


def main(*argv: str) -> None:
    """ Executed when run from the command line """
    configs_base_dir = get_dropbox_dir() / 'config'
    host_configs_dir = configs_base_dir / f'@{get_hostname()}'
    link_configs(host_configs_dir)
    try:
        group_configs_dir = get_group_configs_dir(configs_base_dir,
                                                  host_configs_dir)
    except OSError:
        group_configs_dir = None

    if group_configs_dir is not None:
        link_configs(group_configs_dir)


if __name__ == '__main__':
    # This is executed when run from the command line
    main(*sys.argv[1:])
