#!/usr/bin/env python3
"""
Scan two directory trees,
and set the modification time of files
located in the same relative path and having the same contents
to the oler of the two.
"""

from __future__ import annotations

import asyncio
import functools
import logging
import os
import re
import stat
from collections import deque
from typing import Callable, Deque, Generator, Optional, ParamSpec, Tuple, TypeVar, Union

import aiofiles

_ARGS = ParamSpec('_ARGS')
_RETURN_TYPE = TypeVar('_RETURN_TYPE')
_QUEUE_CONTENTS_TYPE = Tuple[str, str, os.stat_result, os.stat_result]
_QUEUE_TYPE = asyncio.Queue[_QUEUE_CONTENTS_TYPE]


def scandir_walk(
    path: str,
    filename_regex: Optional[Union[str, re.Pattern]] = None,
    follow_symlinks: bool = False,
) -> Generator[os.DirEntry, None, None]:
    """ Walk a directory tree using os.scandir() """
    for entry in os.scandir(path):
        if entry.is_dir():
            yield from scandir_walk(entry.path,
                                    filename_regex=filename_regex,
                                    follow_symlinks=follow_symlinks)
        elif ((follow_symlinks or not entry.is_symlink())
              and entry.is_file(follow_symlinks=follow_symlinks)
              and (filename_regex is None
                   or re.match(filename_regex, os.path.basename(entry.path)))):
            yield entry


async def files_have_same_contents(firstpath: str, secondpath: str) -> bool:
    """ Check if all the files have the same contents """

    blocksize: int = 2 * 1024 * 1024

    # read first two files in parallel
    async with aiofiles.open(firstpath, 'rb') as f0:
        async with aiofiles.open(secondpath, 'rb') as f1:
            while True:
                f0data, f1data = await asyncio.gather(f0.read(blocksize),
                                                      f1.read(blocksize))
                if f0data != f1data:
                    return False
                if not f0data:
                    break
    return True


class QueueGetContext:
    """ Context manager to get an item from a queue """

    def __init__(self, queue: _QUEUE_TYPE) -> None:
        self.queue = queue

    async def __aenter__(self) -> _QUEUE_CONTENTS_TYPE:
        return await self.queue.get()

    async def __aexit__(self, exc_type, exc_value, traceback) -> None:
        self.queue.task_done()


async def coproc_compare_files(queue: _QUEUE_TYPE,
                               call_if_same: Callable) -> None:
    """ Compare files in the queue """

    while True:
        async with QueueGetContext(queue) as (path1, path2, path1stat, path2stat):
            # Check contents
            if await files_have_same_contents(path1, path2):
                # Update mtime
                await call_if_same(path1, path2, path1stat, path2stat)
            else:
                logging.debug('%s and %s have different contents', path1,
                              path2)


def decide_mtimes(
        path1: str, path2: str, path1stat: os.stat_result,
        path2stat: os.stat_result) -> Tuple[str, Tuple[float, float]]:
    if path1stat.st_mtime > path2stat.st_mtime:
        updatepath = path1
        olderpath = path2
        updatetimes = (path1stat.st_atime, path2stat.st_mtime)
    else:
        updatepath = path2
        olderpath = path1
        updatetimes = (path2stat.st_atime, path1stat.st_mtime)
    logging.debug('%s is newer than %s', updatepath, olderpath)
    return updatepath, updatetimes


async def set_mtime_to_older(path1: str, path2: str, path1stat: os.stat_result,
                             path2stat: os.stat_result) -> None:
    updatepath, updatetimes = decide_mtimes(path1, path2, path1stat, path2stat)
    logging.info('Setting %s mtime', updatepath)
    os.utime(updatepath, updatetimes)


async def print_mtime_of_older(path1: str, path2: str,
                               path1stat: os.stat_result,
                               path2stat: os.stat_result) -> None:
    updatepath, _ = decide_mtimes(path1, path2, path1stat, path2stat)
    logging.info('Would update %s mtime', updatepath)


async def compare_dirs_update_mtimes(  # pylint: disable=too-many-locals
        dir1: str,
        dir2: str,
        filename_regex: Optional[Union[str, re.Pattern]] = None,
        dry_run: bool = False) -> None:
    """ Scan two directory trees,
        and set the modification time of files
        located in the same relative path and having the same contents
        to the oler of the two
    """

    dir1 = os.path.abspath(dir1)
    dir2 = os.path.abspath(dir2)

    if dir1 == dir2:
        raise ValueError('Directories are the same')
    for d in [dir1, dir2]:
        if not os.path.isdir(d):
            raise ValueError(f'Not a directory: {d}')

    total_count = 0
    processed_count = 0
    matched_count = 0

    def _with_count(
        fn: Callable[_ARGS, _RETURN_TYPE], ) -> Callable[_ARGS, _RETURN_TYPE]:

        @functools.wraps(fn)
        def wrapped(*args, **kwargs) -> _RETURN_TYPE:
            nonlocal matched_count
            matched_count += 1
            return fn(*args, **kwargs)

        return wrapped

    queue: asyncio.Queue = asyncio.Queue(maxsize=2)
    local_queue: Deque[asyncio.Task] = deque()
    processors = asyncio.create_task(
        coproc_compare_files(
            queue,
            _with_count(print_mtime_of_older)
            if dry_run else set_mtime_to_older))

    for entry in scandir_walk(dir1, filename_regex=filename_regex):
        total_count += 1
        path1 = entry.path
        path2 = os.path.join(dir2, os.path.relpath(path1, dir1))
        try:
            path2stat = os.stat(path2, follow_symlinks=False)
        except FileNotFoundError:
            logging.debug('%s does not exist', path2)
            continue
        # Check attrubites
        if not stat.S_ISREG(path2stat.st_mode):
            logging.debug('%s is not a regular file', path2)
            continue
        path1stat = entry.stat(follow_symlinks=True)
        if (path1stat.st_size != path2stat.st_size):
            logging.debug('%s and %s have different sizes', path1, path2)
            continue
        if path1stat.st_mtime == path2stat.st_mtime:
            logging.debug('%s and %s have the same modification time', path1,
                          path2)
            continue
        local_queue.append(
            asyncio.create_task(queue.put(
                (path1, path2, path1stat, path2stat))))
        processed_count += 1

    # ensure all tasks are queued
    await asyncio.gather(*local_queue)
    # wait for all tasks to complete
    await queue.join()
    processors.cancel()
    logging.info(
        '%d files total, %d files compared by contents, %d files were matching',
        total_count, processed_count, matched_count)


def main() -> None:
    import argparse  # pylint: disable=import-outside-toplevel
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('dir1', help='First directory')
    parser.add_argument('dir2', help='Second directory')
    parser.add_argument('--filename-regex', '-r', help='File name regex')
    parser.add_argument('--dry-run',
                        '-n',
                        action='store_true',
                        help='Dry run (do not change anything)')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)
    asyncio.run(
        compare_dirs_update_mtimes(args.dir1,
                                   args.dir2,
                                   filename_regex=args.filename_regex,
                                   dry_run=args.dry_run))


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
