#!/usr/bin/env python3
'''
Keeps one hardlink per file in a directory.
'''

from __future__ import annotations, generator_stop

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import (DefaultDict, NoReturn, Optional, Set)
from collections import defaultdict
from fnmatch import fnmatch
import logging
import os
import sys

# Third-Party modules, see https://pypi.org/
import win32file  # https://pypi.org/project/pywin32/

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


LINKED_PATHS_TYPE = DefaultDict[int, DefaultDict[str, set[str]]]


def find_hardlinks(
        dir: str,
        mask: Optional[str],
        linked_paths: Optional[LINKED_PATHS_TYPE] = None) -> LINKED_PATHS_TYPE:
    if linked_paths is None:
        linked_paths = defaultdict(lambda: defaultdict(set))
    dirs: list[str] = []
    for de in os.scandir(dir):
        if de.is_dir(follow_symlinks=False):
            dirs.append(de.path)
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
        for hardlink in hardlinks_list:
            linked_paths[ino][os.path.dirname(hardlink)].add(
                os.path.basename(hardlink))
    for d in dirs:
        try:
            find_hardlinks(d, mask, linked_paths)
        except OSError as e:
            log.warning('%s: %s', type(e).__name__, d)
    log.debug('linked_paths: %s', linked_paths)
    return linked_paths


def main() -> NoReturn:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('dir', help='Directory to scan for hardlinks')
    parser.add_argument('--mask', '-m', help='Shell mask for files.')
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

    # inode -> {dir -> {filenames}}

    inode_dir_filenames = find_hardlinks(args.dir, args.mask)
    for dirsfilenames in inode_dir_filenames.values():
        for dirname, filenames_set in dirsfilenames.items():
            if len(filenames_set) <= 1:
                continue
            if log.isEnabledFor(logging.DEBUG):
                log.debug('%i hardlinks in %s:\n\t%s', len(filenames_set),
                          dirname, '\n\t'.join(filenames_set))
            if not args.dry_run:
                removed = 0
                filenames = sorted(filenames_set)
                remaining_files = set(filenames)
                for filename in sorted(filenames)[1:]:
                    log.debug('removing %s', os.path.join(dirname, filename))
                    try:
                        os.remove(os.path.join(dirname, filename))
                        removed += 1
                        remaining_files.remove(filename)
                    except OSError:
                        log.exception('failed to remove %s')
                log.info('Removed %i hardlinks of %s\\%s', removed, dirname,
                         filenames[0])
                dirsfilenames[dirname] = remaining_files
    # Print what remains
    if log.isEnabledFor(logging.INFO):
        log.info('Remaining hardlinks:')
        for ino, dirsfilenames in inode_dir_filenames.items():
            log.info('Inode %i:', ino)
            for dirname, filenames_set in dirsfilenames.items():
                if len(filenames_set) == 1:
                    log.info('\t%s\\%s', dirname,
                             iter(filenames_set).__next__())
                else:
                    log.info('\t%s:', dirname)
                    for filename in filenames_set:
                        log.info('\t\t%s', filename)
    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
