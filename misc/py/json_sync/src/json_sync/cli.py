#!/usr/bin/env python3
""" Apply changes made to JSON files to all specified files.

Imagine you have 2 JSON files, `file1.json` and `file2.json`:
`file1.json`:
```json
{
    "key1": "value1",
    "key2": "value2"
}
```
`file2.json`:
```json
{
    "key1": "value1",
    "key2": "different_value2",
    "key3": "value3"
}
```

When you run the script the first time, it will create previous version files
`file1.json.prev` and `file2.json.prev` to track changes, but will not yet
modify the files.

If you then modify `file1.json` to change `key2` to `new_value2`:
```json
{
    "key1": "value1",
    "key2": "new_value2"
}
```

Running this script with both files as arguments will re-apply the change to
`file2.json`, keeping all other keys intact:
{
    "key1": "value1",
    "key2": "new_value2",
    "key3": "value3"
}
(and update both `.prev` files accordingly).

You can also specify a filter JSON file to limit which keys are synchronized.
"""
from __future__ import annotations

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import logging
import os
from pathlib import Path
from typing import Optional, Tuple

# Installable modules https://pypi.org/
# Local modules
from .engine import load_json, sync_json_changes

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(default: int = logging.INFO) -> Tuple[int, Optional[str]]:
    """ Get the log level from the environment variable LOG_LEVEL """
    # pylint: disable=R0801,duplicate-code
    env_debug = os.getenv('DEBUG', '')
    if env_debug > '0' and env_debug[:1].lower() not in ('n', 'f'):
        return logging.DEBUG, None
    try:
        env_log_level = os.environ['LOG_LEVEL']
    except KeyError:
        return default, None
    valid_log_levels = {'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'}
    if env_log_level not in valid_log_levels:
        return default, (f'Invalid log level {env_log_level}, '
                         f'must be one of {", ".join(valid_log_levels)}')
    return getattr(logging, env_log_level.upper()), None


def parse_args() -> argparse.Namespace:
    """ Parse command line arguments """

    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument(
        'json_files',
        type=Path,
        nargs='+',
        help='Paths to at least 2 JSON files to synchronize')
    ap.add_argument(
        '--filter',
        '-f',
        type=Path,
        help='Path to a JSON file specifying which keys to synchronize')
    ap.add_argument(
        '--prev-suffix',
        '-s',
        type=str,
        default='.prev',
        help='Suffix for previous version files (default: %(default)s)')
    ap.add_argument(
        '--prev-dir',
        '-d',
        type=Path,
        help='(Sub-)Directory for previous version files')
    ap.add_argument('--debug', action='store_true', help='Enable debug logging')
    ap.add_argument('--log-file', type=Path, help='Path to log file')
    args = ap.parse_args()
    if len(args.json_files) < 2:
        raise argparse.ArgumentError(None,
                                     'At least 2 JSON files must be specified')
    return args


def config_logging(debug: bool, log_file: Optional[Path]) -> None:
    if debug:
        logging.basicConfig(level=logging.DEBUG)
        return
    log_level, env_log_level_error = get_env_log_level()
    logging_args = {} if log_file is None else {
        'handlers': [
            logging.FileHandler(log_file, encoding='utf-8'),
            logging.StreamHandler()
        ]
    }
    logging.basicConfig(level=log_level, **logging_args)
    if env_log_level_error is not None:
        log.warning(env_log_level_error)


def main() -> None:
    """ Executed when run from the command line """
    args = parse_args()
    config_logging(args.debug, args.log_file)

    sync_json_changes(args.json_files,
                      None if args.filter is None else load_json(args.filter),
                      args.prev_dir, args.prev_suffix)


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
