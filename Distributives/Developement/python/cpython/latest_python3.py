#!/usr/bin/env python3
'''
Download the latest version of Python 3, either source or binary depending on current OS.
On Linux, also build and install it to $HOME/.local.
On Windows, install to default per-user location ("%LOCALAPPDATA%\Programs" for 3.11, see https://docs.python.org/3.11/using/windows.html)

Requires lxml for normal work, and lxml-stubs for developing/debugging.

by LogicDaemon <www.logicdaemon.ru> / <t.me/logicdaemon_pub>
'''

from __future__ import annotations

# Built-in modules
from typing import Generator, Iterable, Optional
import sys
import os
import os.path
import posixpath
import tempfile
import logging
import time
from urllib.parse import urlsplit
from urllib.request import urlopen, HTTPError
import email.utils
# Installable standard modules
import lxml
import lxml.html
from packaging import version
#import configparser
# Installable 3rd party modules
# Our own modules


def main() -> None:
    # get python version in 3.11 format
    pyver = version.parse('.'.join(map(str, sys.version_info[:3])))
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        'mode',
        choices=['check', 'download', 'download_all', 'build', 'install'],
        help=r''''check' just outputs currently latest version
                 'download' downloads the latest binary or source depending on current OS
                 'download_all' downloads both windows 64 bit and source
                 'build' builds the source (currently only on Linux)
                 'install' on Linux, downloads the source, builds and installs it to users's $HOME/.local;
                           on Windows, downloads binary and installs to default per-user location ("%%LOCALAPPDATA%%\Programs" for 3.11, see https://docs.python.org/3.11/using/windows.html)'''
    )
    parser.add_argument('--version-prefix',
                        '-p',
                        required=False,
                        default='3',
                        help='Version prefix (default: %(default)s)')
    parser.add_argument('--above-version',
                        '-a',
                        required=False,
                        default=pyver,
                        type=version.parse,
                        help='Search for a version above the specified (default: %(default)s)')
    parser.add_argument('--destination',
                        '--target',
                        '-t',
                        default='',
                        help='Destination directory')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    dl_all = args.mode == 'download_all'
    on_plain_windows = os.name == 'nt'
    on_posix = os.name == 'posix'

    for ver in get_latest_python_version(args.version_prefix,
                                         args.above_version):
        if args.mode == 'check':
            print(ver)
            sys.exit(0)

        src_url = f'https://www.python.org/ftp/python/{ver}/Python-{ver}.tar.xz'
        w64_url = f'https://www.python.org/ftp/python/{ver}/python-{ver}-amd64.exe'
        logging.info('Latest Python version %s, urls:\n%s\n%s', ver, src_url,
                     w64_url)

        try:
            if dl_all or on_plain_windows:
                windows_dist_path = os.path.join(args.destination,
                                                 f'python-{ver}-amd64.exe')
                download_file(w64_url, windows_dist_path)
            else:
                windows_dist_path = None
            if dl_all or on_posix:
                src_path = os.path.join(args.destination,
                                        f'Python-{ver}.tar.xz')
                download_file(src_url, src_path)
            else:
                src_path = None
        except HTTPError:
            logging.exception('A download failed, trying other version...')
            continue
        break
    else:
        logging.error('No suitable version found')
        sys.exit(1)
    if args.mode in ['download', 'download_all']:
        sys.exit(0)
    if args.mode == 'build' or (on_posix and args.mode == 'install'):
        assert src_path
        build_source(ver, src_path, args.mode == 'install')
    else:  # if args.mode == 'install' and on_plain_windows:
        assert windows_dist_path
        install_on_windows(windows_dist_path)


class ChDir:

    def __init__(self, path: str) -> None:
        self.path = path
        self.prevdir = os.getcwd()

    def __enter__(self) -> None:
        os.chdir(self.path)

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        os.chdir(self.prevdir)


def build_source(pyver: str, path: str, install: bool = False) -> None:
    # 'curl https://www.python.org/ftp/python/$pyver/Python-$pyver.tar.xz | xz -d | tar -xf -',
    errorcode = os.system(f'''bash -c "xz -dkc '{path}' | tar -xf -"''')
    if errorcode != 0:
        logging.error('Failed to extract source')
        sys.exit(1)
    with ChDir(f'Python-{pyver}'):
        commands = [
            'sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev',
            f'./configure --prefix="{os.environ["HOME"]}/.local" --enable-optimizations',
            'bash -c "make -j$(nproc)"',
        ]
        for c in commands:
            errorcode = os.system(c)
            if errorcode != 0:
                logging.error('Command %s returned error %s', c, errorcode)
        if install:
            os.system('make install')


def install_on_windows(dist_path: str) -> None:
    # check HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem LongPathsEnabled
    # https://docs.python.org/3.11/using/windows.html#removing-the-max-path-limitation
    import winreg
    with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                        r'SYSTEM\CurrentControlSet\Control\FileSystem') as key:
        if winreg.QueryValueEx(key, 'LongPathsEnabled')[0] != 1:
            logging.warning('LongPathsEnabled is not set to 1')

    # dest = os.path.join(os.environ['LOCALAPPDATA'], 'Programs')
    os.system(
        f'"{dist_path}" /passive InstallAllUsers=0 InstallLauncherAllUsers=0')


def download_file(url, destination: Optional[str] = None) -> str:
    logging.info('Downloading %s...', url)
    with urlopen(url) as dl:
        if dl.status != 200:
            logging.error('Failed to download %s, code %s %s', url, dl.status,
                          dl.reason)
            sys.exit(1)
        if not destination:
            # cgi is deprecated
            # server_filename = cgi.parse_header(dl.getheader('Content-Disposition',
            #                                       ''))[1].get('filename', '')
            server_filename = dl.headers.get_filename('')
            destination = (posixpath.basename(urlsplit(dl.url).path)
                           or posixpath.basename(server_filename)
                           or tempfile.mktemp())

        last_modified = email.utils.parsedate(dl.getheader('last-modified'))
        # check that currently downloaded file is not the same as on the server
        if last_modified and os.path.exists(destination):
            if abs(os.path.getmtime(destination) - time.mktime(last_modified)
                   ) < 60:  # 1 minute difference is ok
                logging.info('File %s is already up-to-date', destination)
                return destination

        logging.debug('Connection with %s established, headers:\n%s', url,
                      dl.getheaders())
        # save the file
        logging.info('Saving to %s...', destination)
        with open(destination, 'wb') as f:
            full_len = int(dl.getheader('content-length', 0))
            acc_len = 0
            while True:
                data = dl.read1()
                if not data:
                    break
                f.write(data)
                acc_len += len(data)
                if full_len:
                    print_progress(current=acc_len, total=full_len)
                else:
                    print('.', end='', flush=True, file=sys.stderr)
        if not full_len:
            print(file=sys.stderr)

    logging.info('Downloading %s complete', destination)

    # set file time to last modified time on server
    if last_modified:
        os.utime(destination, (time.time(), time.mktime(last_modified)))
    return destination


def get_latest_python_version(
    prefix: str = '',
    above_version: Optional[version.Version] = None
) -> Generator[str, None, None]:
    if prefix:
        major_ver = (prefix[:prefix.index('.')] if '.' in prefix else prefix)
    elif above_version:
        major_ver = str(above_version.major)
    else:
        major_ver = str(sys.version_info.major)
    for ver in get_latest_python_version_unchecked(major_ver):
        if (ver.startswith(prefix)
                and (not above_version or version.parse(ver) > above_version)):
            yield ver


def get_latest_python_version_unchecked(
        major_ver: str) -> Generator[str, None, None]:
    python_release_text_prefix = f'Latest Python {major_ver} Release - Python '
    python_release_text_prefix_len = len(python_release_text_prefix)
    xpath = '/html/body/div/div[3]/div/section/article/ul/li/a'

    with urlopen('https://www.python.org/downloads/source/') as response:
        version_page = lxml.html.fromstring(response.read())
    xpo = version_page.xpath(xpath)
    try:
        assert isinstance(xpo, Iterable)  # for mypy
        for a in xpo:
            # assert isinstance(a, lxml.html._Element)  # doesn't work without lxml stubs
            t = a.text  # type: ignore  # for mypy
            if t:
                assert isinstance(t, str)
                if t.startswith(python_release_text_prefix):
                    yield t[python_release_text_prefix_len:]
    except AssertionError:
        pass

    # not found using xpath, try all links
    for a in version_page.findall('.//a'):
        if a.text and a.text.startswith(python_release_text_prefix):
            ver = a.text[python_release_text_prefix_len:]
            yield ver


# Print iterations progress, from https://stackoverflow.com/a/34325723/1421036
def print_progress(current,
                   total,
                   prefix='',
                   suffix='',
                   decimals=1,
                   length=76,
                   fill='█',
                   printEnd="\r"):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 *
                                                     (current / float(total)))
    filledLength = int(length * current // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}',
          end=printEnd,
          flush=True,
          file=sys.stderr)
    # Print New Line on Complete
    if current == total:
        print()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
