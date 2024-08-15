#!/usr/bin/env python3
""" download https://www.ghisler.com/download.htm
parse it
download 3 TCs from there
"""

from __future__ import annotations, generator_stop

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import NoReturn, Optional, TypedDict
import email.utils
import logging
import os
import posixpath
import re
import sys
import time

# Installable modules, see https://pypi.org/
import dns.resolver
import httpx
import lxml
import lxml.html
from packaging import version

from rich import progress
# except ImportError:
#     from pip._vendor.rich import progress

VERSION_FILE_NAME = 'VERSION'
VERSION_FILE_ENCODING = 'oem'

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)

HttpxArgs = TypedDict('HttpxArgs', {
    'http2': bool,
    'follow_redirects': bool,
},
                      total=False)

httpx_client_default_args = HttpxArgs(
    http2=True,
    follow_redirects=True,
)

shared_httpx_client: Optional[httpx.Client] = None


def init_httpx_client() -> httpx.Client:
    global shared_httpx_client
    if shared_httpx_client is None:
        shared_httpx_client = httpx.Client(**httpx_client_default_args)
    return shared_httpx_client


def get_env_log_level(
        default=logging.DEBUG if __debug__ else logging.INFO) -> int:
    """ Get the log level from the environment variable LOG_LEVEL """
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level not in ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


class TotalCmdDownloads:
    version: version.Version
    download_urls: list[httpx.URL]
    __slots__ = tuple(__annotations__)

    def __init__(self) -> None:
        httpx_client = init_httpx_client()
        url = httpx.URL('https://www.ghisler.com/download.htm')
        page = lxml.html.fromstring(httpx_client.get(url).content)

        assert isinstance(page, lxml.html.HtmlElement)
        # /html/body/table/tbody/tr[2]/td[2]/h3[1]/font/text()[1]
        for header in page.xpath('//h3/*'):
            text = header.text
            if text is None:
                continue
            m = re.search(
                r'Download\s*version\s+(?P<ver>[\d.]+)\s+of\s+Total\s+Commander',
                text.strip(), re.IGNORECASE | re.MULTILINE)
            if m:
                self.version = version.Version(m.group('ver'))
                break
        else:
            raise ValueError('Cannot find version number')

        # /html/body/table/tbody/tr[2]/td[2]/ul[1]
        # <ul>
        #     <li><a href="https://totalcommander.ch/1102/tcmd1102x32.exe"><font size="2" face="Arial"><b>32-bit version only</b></font></a><font size="2" face="Arial"> (Windows 95 up to Windows
        #         11, runs on 32-bit AND 64-bit machines!)</font></li>
        #     <li><a href="https://totalcommander.ch/1102/tcmd1102x64.exe"><font size="2" face="Arial"><b>64-bit version only</b></font></a><font size="2" face="Arial"> (Windows XP up to Windows
        #         11, runs ONLY on 64-bit machines!)</font></li>
        #     <li><a href="https://totalcommander.ch/1102/tcmd1102x32_64.exe"><font size="2" face="Arial"><b>64-bit+32-bit combined
        #         download</b></font></a><font size="2" face="Arial"> (Windows 95 up to Windows 11,
        #         32-bit AND 64-bit machines!)</font></li>
        #     <li><font size="2" face="Arial">Insecure downloads
        #         via http: </font><a href="http://totalcommander.ch/1102/tcmd1102x32.exe"><font size="2" face="Arial"><b>32-bit</b></font></a><font size="2" face="Arial"><b> | </b></font><a href="http://totalcommander.ch/1102/tcmd1102x64.exe"><font size="2" face="Arial"><b>64-bit</b></font></a><font size="2" face="Arial"><b> | </b></font><a href="http://totalcommander.ch/1102/tcmd1102x32_64.exe"><font size="2" face="Arial"><b>64-bit+32-bit combined</b></font></a></li>
        # </ul>
        self.download_urls = [
            url.join(short_url) for short_url in page.xpath(  # type: ignore
                '//ul[1]//a/@href')
            if not short_url.startswith('http://') and '.exe' in short_url
        ]
        log.info('%s', self)

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}({' '.join(getattr(self, v) for v in self.__slots__)})'

    def __str__(self) -> str:
        return f'{self.__class__.__name__} {self.version} ({self.download_urls})'


def download_file(
    url: httpx.URL,
    dest_dir: str,
    progressbar: Optional[progress.Progress],
) -> str:
    httpx_client = init_httpx_client()
    logging.info('Downloading %s...', url)
    while True:  # for redirects
        with httpx_client.stream('GET', url, follow_redirects=True) as dl:
            dl.raise_for_status()
            logging.debug('Connection with %s established, headers:\n%s', url,
                          dl.headers)
            content_disposition = dl.headers.get('Content-Disposition')
            if content_disposition is None:
                server_filename = dl.url.path
            else:
                server_filename = email.utils.parseaddr(
                    content_disposition)[1] or dl.url.path

            destination_fname: str = posixpath.basename(server_filename)
            if not destination_fname:
                raise ValueError(
                    f'Cannot determine destination filename from {server_filename}'
                )

            destination = os.path.join(dest_dir, destination_fname)
            tmp_destination = destination + '.tmp'
            full_len = int(dl.headers.get('content-length', 0))
            logging.info('Saving %i bytes to %s...', full_len, destination)
            last_modified = email.utils.parsedate(
                dl.headers.get('last-modified'))
            # check that currently downloaded file is not the same as on the server
            if last_modified and os.path.exists(destination):
                if abs(
                        os.path.getmtime(destination) -
                        time.mktime(last_modified)
                ) < 60:  # 1 minute difference is ok
                    logging.info('File %s is already up-to-date', destination)
                    break
            # save the file
            with open(destination, 'wb'), open(tmp_destination, 'wb') as f:
                progress_task_id = (progressbar.add_task(
                    destination_fname, total=full_len) if full_len
                                    and progressbar is not None else None)
                accumulated_len = 0
                for chunk in dl.iter_bytes():
                    inc_len = f.write(chunk)
                    accumulated_len += inc_len
                    if progress_task_id is None:
                        print('.', end='', flush=True, file=sys.stderr)
                    else:
                        assert progressbar is not None
                        # print_progress(current=acc_len, total=full_len)
                        progressbar.update(progress_task_id,
                                           completed=accumulated_len)
            os.replace(tmp_destination, destination)
            if progress_task_id is None:
                print(file=sys.stderr)
            else:
                assert progressbar is not None
                progressbar.remove_task(progress_task_id)

            logging.info('Downloading %s complete', destination)

            # set file time to last modified time on server
            if last_modified:
                os.utime(destination,
                         (time.time(), time.mktime(last_modified)))
            break
    return destination


def update_descript_ion(path: str, description: str) -> None:
    """ Update descript.ion file for the given path with the given description
        Accroding to https://stackoverflow.com/a/15808848/1421036, descript.ion
        file format is:
        ```
        Filename This is the first line\\nSecond line\\nLast line\x04\xc2
        "Filename with spaces" This is the first line\\nSecond line\\nLast line\x04\xc2
        ```
        The `descript.ion` file contains a backslash and a letter 'n' in place
        of a line break, and two special characters 04 C2 at the end of the
        comment. In addition, the line is ended by a Windows line break 0D 0A.

        Apparently, the two extra characters at the end of the line signal the
        end of a multiline comment. If removed, the comment is rendered as a
        single line in the GUI, and the '\n' sequences are displayed literally.
    """
    dirname = path
    while dirname:
        dirname, desc_fname = os.path.split(dirname)
        if desc_fname:
            break
    else:
        raise ValueError(f'Cannot determine description file name for {path}')

    if '\n' in description:
        description = description.replace('\n', '\\n')
        multiline_description_suffix = '\x04\xc2'
    else:
        multiline_description_suffix = ''

    desc_fname = f'"{desc_fname}"' if ' ' in desc_fname else desc_fname
    descript_ion_path = os.path.join(dirname, 'descript.ion')
    descript_ion_fname_tmp = descript_ion_path + '.tmp'
    try:
        with open(descript_ion_path) as f2:
            orig = f2.read()
    except FileNotFoundError:
        orig = ''
    curr_desc_line_pos = (0 if orig.startswith(desc_fname + ' ') else
                          orig.find(f'\n{desc_fname} '))
    if curr_desc_line_pos >= 0:
        curr_desc_offset = curr_desc_line_pos + len(desc_fname)
        next_desc_pos = orig.find('\n', curr_desc_line_pos + 1) + 1
        current_desc = orig[curr_desc_offset:next_desc_pos].rstrip('\r\n')
        if description in current_desc:
            return
        if current_desc.endswith(multiline_description_suffix):
            # remove duplicating suffix
            multiline_description_suffix = ''
        descript_ion = (
            f'{orig[:curr_desc_offset]} {description} {current_desc}{multiline_description_suffix}\n'
            + (orig[next_desc_pos:] if next_desc_pos else ''))
    else:
        descript_ion = f'{desc_fname} {description}{multiline_description_suffix}\n'

    with open(descript_ion_fname_tmp, 'w') as f:
        f.write(descript_ion)
    os.replace(descript_ion_fname_tmp, descript_ion_path)


def query_current_version():
    # current version is available in txt DNS record of releaseversion.ghisler.com
    # in format '10.11.2.0;1'
    host = 'releaseversion.ghisler.com'
    answer = dns.resolver.resolve(host, 'TXT')
    assert str(answer.qname) == f'{host}.'
    for rdata in answer:  # pyright: ignore[reportGeneralTypeIssues]
        for txt_bytes in rdata.strings:
            txt_string = txt_bytes.decode('utf-8')
            if re.match(r'[\d.]+(;\d+)?', txt_string):
                return txt_string
    return None


def read_saved_ver(dest_dir: str) -> str | None:
    try:
        with open(os.path.join(dest_dir, VERSION_FILE_NAME),
                  encoding=VERSION_FILE_ENCODING) as f:
            return f.readline().strip()
    except FileNotFoundError:
        pass
    return None


def save_ver(dest_dir: str, ver: str) -> None:
    with open(os.path.join(dest_dir, VERSION_FILE_NAME),
              'w',
              encoding=VERSION_FILE_ENCODING) as f:
        f.write(ver)


def main() -> NoReturn:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    # parser.add_argument('action',
    #                     choices=('download', 'check'),
    #                     default='check')
    parser.add_argument('--dest-dir', '-D', help='Destination directory')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.debug else get_env_log_level())

    dest_dir = args.dest_dir or os.environ.get('srcpath') or os.getcwd()

    cur_ver = query_current_version()
    saved_ver = read_saved_ver(dest_dir)
    if cur_ver == saved_ver:
        log.info('Current version %s is the same as last saved %s', cur_ver,
                 saved_ver)
        sys.exit()
    log.info('Current version %s is different from last saved %s', cur_ver,
             saved_ver)

    init_httpx_client()
    dl_info = TotalCmdDownloads()
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
        for url in dl_info.download_urls:
            try:
                dest = download_file(url, dest_dir, progressbar)
            except Exception:
                log.exception('Downloading %s failed', url)
                continue
            print(dest)
            update_descript_ion(dest, f'URL: {url}')

    if cur_ver is not None:
        save_ver(dest_dir, cur_ver)

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
