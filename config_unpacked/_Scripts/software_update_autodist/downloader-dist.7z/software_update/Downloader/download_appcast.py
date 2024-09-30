#!/usr/bin/env python3
"""
Downloads the last file from an appcast feed if it has been modified
since the last download
"""

# import modules used here -- sys is a very standard one
import os
import pathlib
import re
import sys
from datetime import datetime
from typing import Optional


def pip_install_req() -> None:
    """ Install the requirements """
    import subprocess  # pylint: disable=C0415,import-outside-toplevel
    script_path = pathlib.Path(__file__)
    req_file = script_path.with_suffix(script_path.suffix +
                                       ' requirements.txt')
    dep_dir = script_path.with_suffix('.deps')
    sys.path.append(str(dep_dir))
    os.environ['PYTHONUSERBASE'] = str(dep_dir)
    python_executable = sys.executable

    subprocess.run([
        python_executable, '-m', 'pip', 'install', '--user', '-r',
        str(req_file)
    ],
                   check=True)


for try_no in range(2):
    try:
        import httpx
        import werkzeug
        import werkzeug.http
        import xmltodict
        break
    except ImportError:
        pip_install_req()
del try_no


def download(cl: httpx.Client,
             url: str,
             fail_when_no_last_modified_header: bool = False) -> Optional[str]:
    """ Download a file from the server if remote is newer
        and set its modification time to the last-modified header
    """
    with cl.stream('GET', url) as r:
        r.raise_for_status()
        print(r.headers, file=sys.stderr)
        content_disp = r.headers.get('content-disposition')
        local_filename: str = werkzeug.utils.secure_filename(
            werkzeug.http.parse_options_header(content_disp)[1]['filename']
            if content_disp is not None else url.rsplit('/', 1)[1])
        last_modified = werkzeug.http.parse_date(
            r.headers.get('last-modified'))
        print('Remote file', local_filename, end=', ', file=sys.stderr)
        if last_modified:
            print('modified', last_modified, file=sys.stderr)
            last_modified_ts = last_modified.timestamp()
            if os.path.exists(local_filename):
                current_time = os.path.getmtime(local_filename)
                if current_time == last_modified_ts:
                    print('File is up to date', file=sys.stderr)
                    return local_filename
                print('Current file exists but has different timestamp,',
                      datetime.fromtimestamp(current_time),
                      file=sys.stderr)
        else:
            print('without last-modified header', file=sys.stderr)
            last_modified_ts = None
            if fail_when_no_last_modified_header:
                print('Skipping', file=sys.stderr)
                return None

        os.makedirs('temp', exist_ok=True)
        tempf = os.path.join('temp', local_filename)
        with open(tempf, 'wb') as f:
            for chunk in r.iter_bytes(chunk_size=65536):
                f.write(chunk)
            if last_modified_ts is not None:
                os.utime(tempf, (last_modified_ts, last_modified_ts))
        os.replace(tempf, local_filename)
        return local_filename


def bool_heuristics(v: str) -> bool:
    """ Convert a string to a boolean """
    if (re.match(r'(?i)(tru|y|on$)', v)
            or (re.match(r'(?i)\d+$', v) and int(v) != 0)):
        return True

    # if v in ('false', 'no', 'off', '0'):
    if (re.match(r'(?i)(f|n|off$)', v)
            or (re.match(r'(?i)\d+$', v) and int(v) == 0)):
        return False
    raise ValueError(f'Unable to interpret the value "{v}" as boolean.')


def main() -> None:
    """ Main program """
    try:
        fail_when_no_last_modified_header = bool_heuristics(sys.argv[2])
    except IndexError:
        fail_when_no_last_modified_header = False
    cl = httpx.Client(http2=True, timeout=60)
    name = download(
        cl,
        xmltodict.parse(cl.get(
            sys.argv[1]).text)['rss']['channel']['item']['enclosure']['@url'],
        fail_when_no_last_modified_header)
    if name is not None:
        print(name)


if __name__ == '__main__':
    main()
