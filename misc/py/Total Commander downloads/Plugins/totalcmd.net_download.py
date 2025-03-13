#!/usr/bin/env python3
""" Download plugins from totalcmd.net """

from __future__ import annotations, generator_stop

import argparse
import email.utils
import logging
import os
import posixpath
import re
import sys
import time
from enum import StrEnum
from typing import NoReturn, Optional, Tuple, TypedDict, Union, Unpack

import httpx
import lxml  # type: ignore
import lxml.html  # type: ignore
from packaging import version

try:
    from rich import progress
except ImportError:
    from pip._vendor.rich import progress

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


def init_httpx_client(**kwargs: Unpack[HttpxArgs]) -> httpx.Client:
    if kwargs:
        return httpx.Client(**(
            httpx_client_default_args  # type: ignore
            | kwargs))
    return httpx.Client(**httpx_client_default_args)


def get_env_log_level(
        default=logging.DEBUG if __debug__ else logging.INFO) -> int:
    """ Get the log level from the environment variable LOG_LEVEL """
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level not in ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


class PluginCategory(StrEnum):
    CONTENT = 'Content'
    FILESYSTEM = 'Filesystem'
    LISTER = 'Lister'
    PACKER = 'Packer'


class TotalcmdNetPluginData:
    urlname: str
    name: str
    version: Union[version.Version, str]
    category: PluginCategory
    download_urls: list[httpx.URL]
    whatsnew: Optional[str]
    __slots__ = tuple(__annotations__)

    def __init__(self,
                 name_in_url: str,
                 category: Optional[PluginCategory] = None,
                 httpx_client: Optional[httpx.Client] = None) -> None:
        if httpx_client is None:
            httpx_client = init_httpx_client(follow_redirects=True)
        self.urlname = name_in_url
        url = httpx.URL(
            f'https://www.totalcmd.net/plugring/{name_in_url}.html')
        page = lxml.html.fromstring(httpx_client.get(url).content)

        assert isinstance(page, lxml.html.HtmlElement)
        name_on_page: str = page.xpath('//h1')[0].text.strip()  # type: ignore
        # 'PE Viewer 3.0.7'
        self.name = name_on_page[:name_on_page.rfind(' ')]
        try:
            self.version = version.Version(
                name_on_page[name_on_page.rfind(' ') + 1:])
        except version.InvalidVersion:
            self.version = name_on_page[name_on_page.rfind(' ') + 1:]

        if category is None:
            category_name = page.xpath(
                '//p[contains(@class, "opis")]/b[contains(text(), "Category")]'
            )[0].tail.strip()  # type: ignore
            # 'TC Lister Plugins'
            # 'Content plugins'
            category_name_match = re.match(r'(?:TC )?(\w+) Plugins',
                                           category_name, re.IGNORECASE)
            if category_name_match is None:
                raise ValueError(f'Unknown category: {category_name}')
            category = PluginCategory(category_name_match.groups(1)[0])
        self.category = category

        self.download_urls = [
            url.join(short_url) for short_url in page.xpath(  # type: ignore
                '//ul[contains(@class, "download_links")]//a/@href')
        ]
        # self.whatsnew = page.xpath('/html/body/table/tbody/tr/td/table[2]/tbody/tr/td[1]/center[2]/textarea')[0].text_content()  # NOQA: E501
        whatsnew_elem_title = "What's new"
        try:
            self.whatsnew = page.xpath(
                f'//center/b[contains(text(), "{whatsnew_elem_title}")]/following::textarea'  # NOQA: E501
            )[0].text  # type: ignore
        except IndexError:
            self.whatsnew = None
        log.info('%s', self)

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}({self.name} {self.version})'

    def __str__(self) -> str:
        return f'{self.name} {self.version} ({self.category})\n{self.download_urls}\n{self.whatsnew}'  # NOQA: E501


def download_file(
    url: httpx.URL,
    dest_dir: str,
    progressbar: Optional[progress.Progress],
    httpx_client: Optional[httpx.Client] = None,
) -> Tuple[str, httpx.URL]:
    """ Download a file
        Return path to the downloaded file and a final URL after redirects """
    if httpx_client is None:
        httpx_client = init_httpx_client(follow_redirects=True)
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
                    f'Cannot determine destination filename from {server_filename}'  # NOQA: E501
                )

            destination = os.path.join(dest_dir, destination_fname)
            tmp_destination = destination + '.tmp'
            full_len = int(dl.headers.get('content-length', 0))
            logging.info('Saving %i bytes to %s...', full_len, destination)
            last_modified = email.utils.parsedate(
                dl.headers.get('last-modified'))
            # check that currently downloaded file is not the same as on the server  # NOQA: E501
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
    return destination, dl.url


def update_descript_ion(path: str, description: str, encoding='utf-8') -> None:
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
    """  # NOQA: E501
    dirname = path
    while dirname:
        dirname, described_file_name = os.path.split(dirname)
        if described_file_name:
            break
    else:
        raise ValueError(f'Cannot determine description file name for {path}')

    lf_is_in_description = '\n' in description
    multiline_desc_suffix = b'\x04\xc2' if lf_is_in_description else b''
    description = description.replace('\n', '\\n')
    enc_description = description.encode(encoding)
    space = ' '.encode(encoding)
    lf = '\n'.encode(encoding)

    described_file_name = (f'"{described_file_name}"' if ' '
                           in described_file_name else described_file_name)
    desc_filename_enc = described_file_name.encode(encoding)
    descript_ion_path = os.path.join(dirname, 'descript.ion')
    descript_ion_fname_tmp = descript_ion_path + '.tmp'
    try:
        with open(descript_ion_path, 'rb') as f2:
            orig = f2.read()
    except FileNotFoundError:
        orig = b''
    if orig:
        curr_desc_line_pos = (0 if orig.startswith(desc_filename_enc + space)
                              else orig.find(lf + desc_filename_enc + space) +
                              len(lf))
    else:
        curr_desc_line_pos = -1
    if curr_desc_line_pos >= 0:
        curr_desc_offset = (curr_desc_line_pos + len(desc_filename_enc) +
                            len(space))
        next_desc_pos = orig.find(lf, curr_desc_offset) + len(lf)
        current_desc = orig[curr_desc_offset:next_desc_pos].rstrip(b'\r' + lf)
        if enc_description in current_desc:
            return
        if current_desc in enc_description:
            current_desc = b''
        lf_is_in_description = lf_is_in_description or lf in enc_description
        if current_desc.endswith(multiline_desc_suffix):
            # remove duplicating suffix
            multiline_desc_suffix = b''
        with open(descript_ion_fname_tmp, 'wb') as f:
            f.write(orig[:curr_desc_offset])
            for token in (
                    enc_description,
                ('\\n'.encode(encoding) if lf_is_in_description else space)
                    if current_desc else b'',
                    current_desc,
                    multiline_desc_suffix,
                    lf,
            ):
                f.write(token)
            if next_desc_pos:
                f.write(orig[next_desc_pos:])
        os.replace(descript_ion_fname_tmp, descript_ion_path)
    else:
        with open(descript_ion_path, 'ab') as f:
            if orig and not orig.endswith(lf):
                f.write(lf)
            f.write(f'{described_file_name} {description}'.encode(encoding))
            f.write(multiline_desc_suffix + lf)


def main() -> NoReturn:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('plugin_name')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.debug else get_env_log_level())

    with init_httpx_client() as httpx_client:
        plugin_data = TotalcmdNetPluginData(args.plugin_name,
                                            httpx_client=httpx_client)
        dest_dir = os.path.join(
            os.path.realpath(os.path.dirname(__file__)),
            'Sorted',
            plugin_data.category.value,
            plugin_data.name,
        )
        if not os.path.isdir(dest_dir):
            os.makedirs(dest_dir)
        if plugin_data.whatsnew:
            whatsnew_fname = os.path.join(dest_dir, 'whatsnew.txt')
            whatsnew_fname_tmp = whatsnew_fname + '.tmp'
            with open(whatsnew_fname_tmp, 'w', encoding='utf-8') as f:
                f.write(plugin_data.whatsnew)
            os.replace(whatsnew_fname_tmp, whatsnew_fname)
        with progress.Progress(
                progress.TextColumn(
                    '[progress.description]{task.description}'),
                progress.BarColumn(),
                progress.TextColumn(
                    '[progress.percentage]{task.percentage:>3.0f}%'),
                # progress.TextColumn('[progress.filesize]{task.completed}'),
                # progress.TextColumn('[progress.filesize]{task.total}'),
                progress.TimeElapsedColumn(),
                progress.TimeRemainingColumn(),
                progress.TransferSpeedColumn(),
        ) as progressbar:
            for url in plugin_data.download_urls:
                try:
                    dest, final_url = download_file(
                        url,
                        dest_dir,
                        progressbar,
                        httpx_client=httpx_client,
                    )
                except Exception:
                    log.exception('Downloading %s failed', url)
                    continue
                if url == final_url:
                    print(f'"{url}" saved to "{dest}"')
                    update_descript_ion(dest, f'URL: {url}')
                else:
                    print(f'"{final_url}" (redirected from "{url}") '
                          f'saved to "{dest}"')
                    update_descript_ion(
                        dest, f'URL: {url}\nRedirected to: {final_url}')

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
