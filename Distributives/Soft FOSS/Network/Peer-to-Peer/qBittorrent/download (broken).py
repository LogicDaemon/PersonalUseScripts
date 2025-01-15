""" Download a current version of qBittorrent """

import os
import pathlib
import sys
from datetime import datetime
from typing import Dict, Never, Optional

SCRIPT_PATH = pathlib.Path(__file__)


def append_sys_path() -> None:
    """ Add the dependencies directory to the path """
    dep_dir = str(SCRIPT_PATH.with_suffix('.deps').absolute())
    sys.path.append(dep_dir)
    os.environ.setdefault('PYTHONUSERBASE', dep_dir)


def restart_with_requirements_installed() -> Never:
    """ Install the requirements """
    import subprocess  # pylint: disable=C0415,import-outside-toplevel
    req_file = SCRIPT_PATH.with_suffix(SCRIPT_PATH.suffix +
                                       ' requirements.txt')
    python_executable = sys.executable
    flag_envvar = f'RESTARTED_{SCRIPT_PATH.stem}'
    if os.environ.get(flag_envvar) == '1':
        print('Restart already attempted', file=sys.stderr)
        os.abort()

    subprocess.run([
        python_executable, '-m', 'pip', 'install', '--user', '-r',
        str(req_file)
    ],
                   check=True)
    os.environ[flag_envvar] = '1'
    print('Restarting:', sys.executable, *sys.argv, file=sys.stderr)
    os.execl(sys.executable, sys.executable, *sys.argv)


for try_no in range(2):
    try:
        import httpx
        import werkzeug
        import werkzeug.http
        import xmltodict
        break
    except ImportError:
        if try_no:
            restart_with_requirements_installed()
        # Try adding the dependencies directory to the path first
        append_sys_path()

del try_no


def download(cl: httpx.Client, url: str, title: Optional[str], *,
             headers: Dict[str, str]) -> Optional[str]:
    """ Download a file from the server if remote is newer
        and set its modification time to the last-modified header
    """
    with cl.stream('GET', url, headers=headers) as r:
        r.raise_for_status()
        print(r.headers, file=sys.stderr)
        content_disp = r.headers.get('content-disposition')
        local_filename: str = title or (werkzeug.utils.secure_filename(
            werkzeug.http.parse_options_header(content_disp)[1]['filename']
            if content_disp is not None else url.rsplit('/', 1)[1]))
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

        os.makedirs('temp', exist_ok=True)
        tempf = os.path.join('temp', local_filename)
        dl_size = 0
        with open(tempf, 'wb') as f:
            for chunk in r.iter_bytes(chunk_size=65536):
                dl_size += f.write(chunk)
            if last_modified_ts is not None:
                os.utime(tempf, (last_modified_ts, last_modified_ts))
        print('\tDownloaded', dl_size, 'bytes', file=sys.stderr)
        os.replace(tempf, local_filename)
        return local_filename


def main() -> None:
    """ Main program """

    cl = httpx.Client(http2=True, timeout=60)
    headers = {
        'referer': 'https://www.fosshub.com/feed/5b8793a7f9ee5a5c3e97a3b2.xml'
    }
    items = xmltodict.parse(
        cl.get('https://www.fosshub.com/feed/5b8793a7f9ee5a5c3e97a3b2.xml',
               headers=headers).text)['release']['items']['item']
    for item in items:
        # <item>
        #   <title>qbittorrent_5.0.0_x64_setup.exe.asc</title>
        #   <link>https://www.fosshub.com/qBittorrent.html?dwl=qbittorrent_5.0.0_x64_setup.exe.asc</link>
        #   <type>PGP</type>
        #   <version>5.0.0</version>
        # </item>
        title = item['title']
        if title.endswith('.exe.asc') or title.endswith('.exe'):
            name = download(cl, item['link'], title, headers=headers)
            if name is not None:
                print(name)


if __name__ == '__main__':
    main()
