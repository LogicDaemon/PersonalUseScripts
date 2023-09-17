#!/usr/bin/env python3
'''
Download Inkscape distributive from https://inkscape.org/release/
'''

from __future__ import annotations, generator_stop

import email.utils
import logging
import os
import re
import sys
import time
# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import Iterable, Iterator, List, Mapping, NoReturn, Optional
from urllib.parse import urlsplit

import httpx
# Installable modules, see https://pypi.org/
import lxml
import lxml.html
from rich import progress

#import configparser

# from pip._vendor.rich import progress  # type: ignore

http_timeout = 10

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(
        default: int = logging.DEBUG if __debug__ else logging.INFO) -> int:
    ''' Get the log level from the environment variable LOG_LEVEL '''
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level not in ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


DLTREEMAP = Mapping[str, 'DLTREEMAP_ELEM']
DLTREEMAP_LEAF = None | str
DLTREEMAP_ELEM = DLTREEMAP_LEAF | DLTREEMAP

windows_distribution_types: DLTREEMAP = {
    'compressed-7z': '7z',
    'msi': None,
    'exe': None,
}

download_types: DLTREEMAP = {
    'windows': {
        '64-bit': windows_distribution_types,
        '32-bit': windows_distribution_types
    },
    'gnulinux': {
        'appimage': None,
        'ppa': None
    },
    'mac-os-x': {
        'dmg': None,
        'dmg-arm64': 'dmg'
    },
    'source': {
        'archive': {
            'xz': 'tar.xz'
        }
    },
}


def main() -> NoReturn:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--type',
        '-t',
        type=DownloadType,
        default='windows/64-bit/compressed-7z',
        help=
        'Download type in form k1[/k2[/k3]], like "windows/64-bit/compressed-7z";\n'
        'Variants for the keys are:\n'
        f'{download_types}')
    parser.add_argument(
        '--dest-dir',
        '-D',
        default=os.environ.get('srcpath', '.'),
        help=
        'Destination directory, default is taken from the environment variable "srcpath", or "."'
    )
    parser.add_argument(
        '--temp-dir',
        '-T',
        default=os.environ.get('workdir', '.'),
        help=
        'Temporary directory, default is taken from the environment variable "workdir", or "."'
    )
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.debug else get_env_log_level())

    with progress.Progress(
            progress.TextColumn('[progress.description]{task.description}'),
            progress.BarColumn(),
            progress.TextColumn(
                '[progress.percentage]{task.percentage:>3.0f}%'),
            # progress.TextColumn('[progress.filesize]{task.completed}'),
            # progress.TextColumn('[progress.filesize]{task.total}'),
            progress.TimeElapsedColumn(),
            progress.TimeRemainingColumn(),
            progress.TransferSpeedColumn(),
    ) as progressbar:
        download_latest_ver(args.type, args.dest_dir, args.temp_dir,
                            progressbar)

    sys.exit()


def get_inkscape_ver_from_site(client: httpx.Client) -> str:
    url = 'https://inkscape.org/release/'
    log.debug('GET %s', url)
    r = client.get(url, follow_redirects=True)

    log.debug('Got %s %s', r.status_code, r.url)
    # DEBUG:download.py:Got 200 https://inkscape.org/release/inkscape-1.3/

    exp_path_prefix = '/release/inkscape-'

    # parse r.url for the version
    assert r.url.path.startswith(exp_path_prefix), 'unexpected URL path'
    return r.url.path[len(exp_path_prefix):].split('/', maxsplit=1)[0]


def find_direct_dl_link(
        client: httpx.Client,
        url: str,
        xpath: str = '//a[text()="click here"]') -> Iterator[str | httpx.URL]:
    ''' Find the <a> element on the page and return its full URL
    '''
    log.debug('GET %s', url)
    r = client.get(url, follow_redirects=True)
    root = lxml.html.fromstring(r.text)
    xpo = root.xpath(xpath)
    assert isinstance(xpo, Iterable)  # for mypy
    for a in xpo:
        href: str = a.attrib['href']  # type: ignore
        if re.match(href, 'https?://'):
            yield href
        else:
            yield httpx.URL(url).join(href)


def filename_from_headers(headers: Mapping[str, str]) -> Optional[str]:
    if 'content-disposition' not in headers:
        return None
    return email.utils.unquote(
        headers['content-disposition'].split('filename=')[1])


def tree_leaf(tree: DLTREEMAP, path: Iterable[str]) -> Optional[str]:
    t: DLTREEMAP_ELEM = tree
    for v in path:
        assert isinstance(t, Mapping)
        t = t[v]
    assert t is None or isinstance(t, str)
    return t


class DownloadType(List[str]):
    leaf: DLTREEMAP_LEAF

    def __init__(self, *args: str) -> None:
        largs = (args[0].split('/')
                 if len(args) == 1 and '/' in args[0] else args)
        if __debug__:
            try:
                tree_leaf(download_types, largs)
            except AssertionError as e:
                raise ValueError(
                    'Download type must be a path to a leaf node in the download_types tree'
                ) from e
        super().__init__(largs)

    def default_filename(self) -> str:
        leaf = tree_leaf(download_types, self)
        if not isinstance(leaf, str):
            leaf = self[-1]
        return '-'.join(self[0:-1] + [leaf])


def download_latest_ver(dl_keys: DownloadType,
                        dest_dir: str = '.',
                        temp_dir: str = '.',
                        progressbar: Optional[progress.Progress] = None):
    ''' Open https://inkscape.org/release/
        It will redirect to the latest version, like https://inkscape.org/release/inkscape-1.3/...

        From there, go to https://inkscape.org/release/inkscape-{ver}/windows/64-bit/compressed-7z/dl/
        and get the "click here" link to download the file

        Same with https://inkscape.org/release/inkscape-{ver}/windows/32-bit/compressed-7z/dl/
    '''

    # Find otu the latest version
    with httpx.Client(http2=True, timeout=http_timeout,
                      follow_redirects=True) as client:
        ver = get_inkscape_ver_from_site(client)
        log.info('Inkscape version on site: %s', ver)

        os.makedirs(temp_dir, exist_ok=True)
        os.makedirs(dest_dir, exist_ok=True)
        # Get the download page
        for dl_url in find_direct_dl_link(
                client,
                f'https://inkscape.org/release/inkscape-{ver}/{"/".join(dl_keys)}/dl/'
        ):
            log.info('Download URL: %s', dl_url)

            # Download the file
            with client.stream('GET', dl_url) as dl:
                log.info('Download status: %s', dl.status_code)
                log.info('Download headers: %s', dl.headers)

                filename = filename_from_headers(dl.headers)
                tmpfpart = (urlsplit(str(dl_url)).path.rsplit('/')[-1]
                            if filename is None else
                            filename) or dl_keys.default_filename()
                tmp_path = os.path.join(temp_dir, tmpfpart + ".tmp")

                dest_path = os.path.join(
                    dest_dir, filename or dl_keys.default_filename())

                last_modified = None
                try:
                    time_tuple = email.utils.parsedate(
                        dl.headers['last-modified'])
                    log.debug('last-modified: %s', time_tuple)
                    if time_tuple is not None:
                        last_modified = time.mktime(time_tuple)
                        if (os.path.exists(dest_path) and
                                os.path.getmtime(dest_path) == last_modified):
                            log.info('%s is up to date', dest_path)
                            continue
                except KeyError:
                    pass

                log.info('Downloading to %s', tmp_path)
                with open(tmp_path, 'wb') as file:
                    p = (None if progressbar is None else progressbar.add_task(
                        tmpfpart, total=int(dl.headers.get('content-length'))))
                    for chunk in dl.iter_bytes():
                        file.write(chunk)
                        if p is not None:
                            assert progressbar is not None
                            progressbar.update(p, advance=len(chunk))
                    if p is not None:
                        assert progressbar is not None
                        progressbar.remove_task(p)
                del p
                if last_modified is not None:
                    os.utime(tmp_path, (last_modified, last_modified))
                    log.debug('File mtime is updated')
                log.debug('Renaming %s to %s', tmp_path, dest_path)
                os.replace(tmp_path, dest_path)


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
