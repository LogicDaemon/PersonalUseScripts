#!/usr/bin/env python3
'''
Removes files from one directory when a hardlink to the same file
present in another directory.
'''

from __future__ import annotations, generator_stop
from fnmatch import fnmatch
import pprint

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import (DefaultDict, Optional, NoReturn)
import sys
import os
import logging
#import configparser

# Installable modules, see https://pypi.org/
import win32file

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(default=logging.INFO) -> int:
    ''' Get the log level from the environment variable LOG_LEVEL '''
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level is None or env_log_level not in ('DEBUG', 'INFO',
                                                      'WARNING', 'ERROR',
                                                      'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


# index → paths
LINKED_PATHS_TYPE = dict[int, list[str]]


def find_hardlinks(
        scan_dir: str,
        dest_dir: str,
        mask: Optional[str],
        recursive: bool = True,
        linked_paths: Optional[LINKED_PATHS_TYPE] = None) -> LINKED_PATHS_TYPE:
    ''' Scans scan_dir for files with hardlinks in dest_dir,
        returns a dict of MFT index numbers to paths in dest_dir
        (or subdirectories of dest_dir if recursive is True).
    '''
    # FindFileNames returns paths without drive letter,
    # cut off the drive letter from dest_dir
    dest_drive, dest_dir = os.path.splitdrive(dest_dir)
    if dest_drive != os.path.splitdrive(scan_dir)[0]:
        raise ValueError('scan_dir and dest_dir must be on the same drive')
    if dest_dir.endswith(os.path.sep):
        dest_dir_with_bs, dest_dir = dest_dir, dest_dir[:-1]
    else:
        dest_dir_with_bs = dest_dir + os.path.sep

    if linked_paths is None:
        linked_paths = {}
    subdirs: list[str] = []
    for de in os.scandir(scan_dir):
        if de.is_dir(follow_symlinks=False):
            if recursive:
                subdirs.append(de.path)
            continue
        if not de.is_file(follow_symlinks=False):
            continue
        if mask is not None and not fnmatch(de.name, mask):
            continue
        stat = os.stat(de.path)
        # check number of hardlinks
        if stat.st_nlink <= 1:
            continue
        ino = stat.st_ino or de.inode()
        if ino in linked_paths:
            continue
        hardlinks_list = win32file.FindFileNames(de.path)
        log.debug('%s [%i]: %i hardlinks:\n\t%s', de.path, ino,
                  len(hardlinks_list), '\n\t'.join(hardlinks_list))
        if len(hardlinks_list) <= 1:
            continue

        linked_paths[ino] = []  # to avoid checking the same file twice,
        # if it is linked to multiple files in scan_dir
        # but none of them are in dest_dir
        if recursive:
            linked_paths[ino].extend(hardlink[len(dest_dir_with_bs):]
                                     for hardlink in hardlinks_list
                                     if hardlink.startswith(dest_dir_with_bs))
        else:
            linked_paths[ino].extend(hardlink[len(dest_dir_with_bs):]
                                     for hardlink in hardlinks_list
                                     if os.path.dirname(hardlink) == dest_dir)
    for subdir in subdirs:
        try:
            find_hardlinks(subdir, dest_dir, mask, recursive, linked_paths)
        except OSError as e:
            log.warning('%s: %s', type(e).__name__, subdir)
    log.debug('linked_paths: %s', linked_paths)
    return linked_paths


def main() -> NoReturn:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('clean_dir', help='Directory to clean')
    parser.add_argument('keep_dir', help='Directory to find the hardlinks in')
    parser.add_argument('--recursive', '-r', action='store_true')
    parser.add_argument('--mask', '-m', help='File mask')
    parser.add_argument('--dry-run',
                        '-n',
                        action='store_true',
                        help='Dry run, do not actually delete files')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.debug else get_env_log_level())

    ino_hardlinks = find_hardlinks(args.keep_dir, args.clean_dir, args.mask,
                                   args.recursive)
    if args.dry_run:
        log.info('Would remove hardlinks:\n%s',
                 pprint.pformat(ino_hardlinks, sort_dicts=False, indent=4))
    else:
        for _, paths in ino_hardlinks.items():
            for path in paths:
                try:
                    rmpath = os.path.join(args.clean_dir, path)
                    os.remove(rmpath)
                    log.info('Removed %s', rmpath)
                except OSError as e:
                    log.warning('%s: %s', type(e).__name__, path)

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
