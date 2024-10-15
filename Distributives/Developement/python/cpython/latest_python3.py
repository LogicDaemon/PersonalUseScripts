#!/usr/bin/env python3
""" Download the latest version of Python 3, either source or binary
    depending on OS.

    On Linux, also build and install it to $HOME/.local.
    On Windows, install to default per-user location ("%LOCALAPPDATA%\\Programs"
        for 3.11, see https://docs.python.org/3.11/using/windows.html)

    Requires lxml for normal work, and lxml-stubs for developing/debugging.

    by LogicDaemon <www.logicdaemon.ru> / <t.me/logicdaemon_pub>
"""

from __future__ import annotations

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import email.utils
import gzip
import logging
import os
import os.path
import posixpath
import sys
import tempfile
import time
from typing import Generator, Iterable, Optional, Self, Union
from urllib.parse import urlsplit
from urllib.request import HTTPError, urlopen

# Installable modules https://pypi.org/
import lxml
import lxml.html

log = logging.getLogger(__file__ if __name__ == '__main__' else __name__)


def main() -> Optional[int]:
    # get python version in 3.11 format
    pyver = version.parse('.'.join(map(str, sys.version_info[:3])))
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        'mode',
        choices=['check', 'download', 'download_all', 'build', 'install'],
        help=("'check' just outputs currently latest version\n"
              "'download' downloads the latest binary or source depending on "
              "current OS\n"
              "'download_all' downloads both windows 64 bit and source\n"
              "'build' builds the source (currently only on Linux)\n"
              "'install' on Linux, downloads the source, builds and installs "
              "it to users's $HOME/.local;\n"
              "          on Windows, downloads binary and installs to "
              r'default per-user location, "%%LOCALAPPDATA%%\Programs" '
              "(see https://docs.python.org/3/using/windows.html)"))
    parser.add_argument(
        '--version-prefix',
        '-p',
        required=False,
        default='3',
        help='Version prefix (default: %(default)s)')
    parser.add_argument(
        '--above-version',
        '-a',
        required=False,
        default=pyver,
        type=version.parse,
        help='Search for a version above the specified (default: %(default)s)')
    parser.add_argument(
        '--below-version',
        '-b',
        required=False,
        default=None,
        type=version.parse,
        help='Search for a version below the specified')
    parser.add_argument(
        '--destination',
        '--target',
        '-t',
        default='',
        help='Destination directory')
    parser.add_argument('--debug', '-d', action='store_true', help='Debug mode')
    args = parser.parse_args()
    log_level = (
        logging.DEBUG if args.debug or os.getenv('DEBUG') else logging.INFO)
    logging.basicConfig(level=log_level)
    logging.debug('Arguments: %s\nLog level: %s', args,
                  logging.getLevelName(log_level))

    dl_all = args.mode == 'download_all'
    on_plain_windows = os.name == 'nt'
    on_posix = os.name == 'posix'

    # Get python version from the site
    for ver in get_matching_python_versions(args.version_prefix,
                                            args.above_version,
                                            args.below_version):
        if args.mode == 'check':
            # just output the first matching version
            # (should be the latest according to the site layout)
            print(ver)
            return 0

        src_url = f'https://www.python.org/ftp/python/{ver}/Python-{ver}.tar.xz'
        # src_url = ver.downloads_page_href
        w64_url = f'https://www.python.org/ftp/python/{ver}/python-{ver}-amd64.exe'
        logging.info('Latest Python version %s, urls:\n%s\n%s', ver, src_url,
                     w64_url)

        try:  # pylint: disable=W0717,too-many-try-statements
            if dl_all or on_plain_windows:
                windows_dist_path = os.path.join(args.destination,
                                                 f'python-{ver}-amd64.exe')
                download_file(w64_url, windows_dist_path)
            if dl_all or on_posix:
                src_path = os.path.join(args.destination,
                                        f'Python-{ver}.tar.xz')
                download_file(src_url, src_path)
        except HTTPError:
            logging.exception('Download failed, trying a next version...')
            continue
        break
    else:
        logging.error('No suitable version found')
        return 1
    if args.mode in ['download', 'download_all']:
        return 0
    assert 'ver' in locals(), 'the else block should have exited'
    if args.mode == 'build' or (on_posix and args.mode == 'install'):
        assert 'src_path' in locals()
        build_source(ver, src_path, args.mode == 'install')
    else:  # if args.mode == 'install' and on_plain_windows:
        assert 'windows_dist_path' in locals()
        install_on_windows(windows_dist_path)


class ChDir:
    """ Context manager to change directory """

    def __init__(self, path: str) -> None:
        self.path = path
        self.prevdir = os.getcwd()

    def __enter__(self) -> None:
        os.chdir(self.path)

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        os.chdir(self.prevdir)


def build_source(pyver: str, path: str, install: bool = False) -> None:
    """ Build and install Python from source """
    # 'curl https://www.python.org/ftp/python/$pyver/Python-$pyver.tar.xz | xz -d | tar -xf -',
    errorcode = os.system(f'''bash -c "xz -dkc '{path}' | tar -xf -"''')
    if errorcode != 0:
        raise RuntimeError('Failed to extract source')
    with ChDir(f'Python-{pyver}'):
        commands = [
            ('sudo apt install build-essential zlib1g-dev libncurses5-dev '
             'libgdbm-dev libnss3-dev libssl-dev libreadline-dev '
             'libffi-dev libsqlite3-dev wget libbz2-dev'),
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
    """ Install downloaded binary on Windows """
    # check HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem LongPathsEnabled
    # https://docs.python.org/3.11/using/windows.html#removing-the-max-path-limitation
    import winreg  # pylint: disable=C0415,import-outside-toplevel
    with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                        r'SYSTEM\CurrentControlSet\Control\FileSystem') as key:
        if winreg.QueryValueEx(key, 'LongPathsEnabled')[0] != 1:
            logging.warning('LongPathsEnabled is not set to 1')

    # dest = os.path.join(os.environ['LOCALAPPDATA'], 'Programs')
    os.system(
        f'"{dist_path}" /passive InstallAllUsers=0 InstallLauncherAllUsers=0')


def download_file(url, destination: Optional[str] = None) -> str:
    """ Download a file displaying progress """
    logging.info('Downloading %s...', url)
    with urlopen(url) as dl:
        if dl.status != 200:
            logging.error('Failed to download %s, code %s %s', url, dl.status,
                          dl.reason)
            raise HTTPError(url, dl.status, dl.reason, dl.getheaders(), None)
        if not destination:
            # cgi is deprecated
            # server_filename = cgi.parse_header(dl.getheader('Content-Disposition',
            #                                       ''))[1].get('filename', '')
            server_filename = dl.headers.get_filename('')
            destination = (
                posixpath.basename(urlsplit(dl.url).path) or
                posixpath.basename(server_filename) or tempfile.mktemp())

        last_modified = email.utils.parsedate(dl.getheader('last-modified'))
        # check that currently downloaded file is not the same as on the server
        if last_modified and os.path.exists(destination):
            if (abs(os.path.getmtime(destination) - time.mktime(last_modified))
                    < 60):  # 1 minute difference is ok
                logging.info('File %s is already up-to-date', destination)
                return destination

        logging.debug('Connection with %s established, headers:\n%s', url,
                      dl.getheaders())
        # save the file
        logging.info('Saving to %s...', destination)
        with open(destination, 'wb') as f:
            full_len = int(dl.getheader('content-length', 0))
            acc_len = 0
            with Progress() as progress:
                task = progress.add_task(
                    os.path.basename(destination), total=full_len)
                while True:
                    data = dl.read1()
                    if not data:
                        break
                    f.write(data)
                    acc_len += len(data)
                    # print_progress(current=acc_len, total=full_len)
                    progress.update(task, completed=acc_len)
        if not full_len:
            print(file=sys.stderr)

    logging.info('Downloading %s complete', destination)

    # set file time to last modified time on server
    if last_modified:
        os.utime(destination, (time.time(), time.mktime(last_modified)))
    return destination


class PyVersion:
    name: str
    number: version.Version
    downloads_page_href: Optional[str]

    def __init__(self, name: str, number: version.Version,
                 href: Optional[str]) -> None:
        self.name = name
        self.number = number
        self.downloads_page_href = href

    def __str__(self) -> str:
        return self.name


def get_matching_python_versions(
    prefix: str = '',
    above_version: Optional[version.Version] = None,
    below_version: Optional[version.Version] = None
) -> Generator[PyVersion, None, None]:
    """ Filter the python versons according to parameters """
    if prefix:
        major_ver = (prefix[:prefix.index('.')] if '.' in prefix else prefix)
    elif above_version:
        major_ver = str(above_version.major)
    else:
        major_ver = str(sys.version_info.major)

    for ver in get_python_versions_unchecked(major_ver):
        if (ver.name.startswith(prefix) and
            (above_version is None or ver.number > above_version) and
            (below_version is None or ver.number < below_version)):
            yield ver
        else:
            logging.debug('Version %s is not suitable', ver)


def get_python_versions_unchecked(
        major_ver: str) -> Generator[PyVersion, None, None]:
    """ Get the latest Python version from www.python.org """
    python_release_text_prefix = f'Latest Python {major_ver} Release - Python '
    python_release_text_prefix_len = len(python_release_text_prefix)
    xpath = '//section/article/ul/li/a'

    with urlopen('https://www.python.org/downloads/source/') as response:
        gzipped = response.getheader('Content-Encoding') == 'gzip'
        if not 200 <= response.status < 300:
            raise HTTPError(response.url, response.status, response.reason,
                            response.getheaders(), response.info())
        data = (gzip.GzipFile(
            fileobj=response,
            mode='rb')).read() if gzipped else response.read()
        if log.level <= logging.DEBUG:
            with open('python_versions.html', 'wb') as f:
                f.write(data)
            log.debug('Saved the page to python_versions.html')
        version_page = lxml.html.fromstring(data)
        del data
    xpo = version_page.xpath(xpath)
    try:  # pylint: disable=W0717,too-many-try-statements
        assert isinstance(xpo, Iterable)  # for mypy
        for a in xpo:
            # assert isinstance(a, lxml.html._Element)  # doesn't work without lxml stubs
            t = a.text  # type: ignore
            if t:
                assert isinstance(t, str)
                if t.startswith(python_release_text_prefix):
                    name = t[python_release_text_prefix_len:]
                    yield PyVersion(name, version.parse(name), a.get('href'))
                else:
                    log.debug('Skipping %s', t)
    except AssertionError:
        pass

    log.debug('not found using xpath "%s", checking all links', xpath)
    for a in version_page.findall('.//a'):
        if a.text and a.text.startswith(python_release_text_prefix):
            name = a.text[python_release_text_prefix_len:]
            yield PyVersion(name, version.parse(name), a.get('href'))


# Print iterations progress, from https://stackoverflow.com/a/34325723/1421036
def update_progress(current,
                    total,
                    prefix='',
                    suffix='',
                    decimals=1,
                    length=None,
                    fill='█',
                    printEnd="\r") -> None:
    """ Call in a loop to create terminal progress bar
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
    if not total:
        print('.', end='', flush=True, file=sys.stderr)
    if length is None:
        length = os.get_terminal_size().columns - 4
    percent = ("{0:." + str(decimals) + "f}").format(100 *
                                                     (current / float(total)))
    length -= len(prefix) + len(suffix) + len(percent) + 7  # 7 is for the bars
    if length > 3:
        filledLength = int(length * current // total)
        progressbar = fill * filledLength + '-' * (length - filledLength)
    else:
        progressbar = r'/-\|'[current % 4]
    print(
        f'\r{prefix} |{progressbar}| {percent}% {suffix}',
        end=printEnd,
        flush=True,
        file=sys.stderr)
    # Print New Line on Complete
    if current == total:
        print()


class ClumsyProgress:
    """ Dummy progress bar for systems without rich """
    # pylint: disable=W0613,unused-argument
    total: Union[int, float]
    __slots__ = tuple(__annotations__)

    def __enter__(self) -> Self:
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        pass

    def add_task(self,
                 description: str,
                 start: bool = True,
                 total: Union[int, float] = 100,
                 completed: int = 0,
                 visible: bool = True,
                 **fields) -> None:
        self.total = total

    def update(self,
               task_id,
               *,
               total: float | None = None,
               completed: float | None = None,
               advance: float | None = None,
               description: str | None = None,
               visible: bool | None = None,
               refresh: bool = False,
               **fields) -> None:
        update_progress(completed, self.total)


try:  # pylint: disable=W0717,too-many-try-statements
    from pip._vendor.packaging import version
    from pip._vendor.rich.progress import Progress
except ImportError:
    from packaging import version
    try:
        from rich.progress import Progress  # pyright: ignore[reportMissingImports]
    except ImportError:
        Progress = ClumsyProgress

if __name__ == '__main__':
    # This is executed when run from the command line
    sys.exit(main())
