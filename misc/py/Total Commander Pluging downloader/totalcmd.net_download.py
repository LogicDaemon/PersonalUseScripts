#!/usr/bin/env -S python3 -O
'''
Download plugins from totalcmd.net
'''

from __future__ import annotations, generator_stop

import email.utils
import logging
import os
import posixpath
import re
import sys
import tempfile
import time
from enum import Enum
from typing import NoReturn, Optional, TypedDict, Unpack

import httpx
import lxml
import lxml.html
from packaging import version

from rich import progress
from torch import dsmm
# except ImportError:
#     from pip._vendor.rich import progress

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
    ''' Get the log level from the environment variable LOG_LEVEL '''
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level not in ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


class PluginCategory(Enum):
    content = 'Content'
    filesystem = 'Filesystem'
    lister = 'Lister'
    packer = 'Packer'


class TotalcmdNetPluginData:
    urlname: str
    name: str
    version: version.Version
    category: PluginCategory
    download_urls: list[httpx.URL]
    whatsnew: str
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
        self.version = version.Version(name_on_page[name_on_page.rfind(' ') +
                                                    1:])

        if category is None:
            category_name = page.xpath(
                '//p[contains(@class, "opis")]/b[contains(text(), "Category")]'
            )[0].tail.strip()  # type: ignore
            # 'TC Lister Plugins'
            category_name_match = re.match(r'TC (\w+) Plugins', category_name)
            if category_name_match is None:
                raise ValueError(f'Unknown category: {category_name}')
            category = PluginCategory(category_name_match.groups(1)[0])
        self.category = category

        self.download_urls = [
            url.join(short_url) for short_url in page.xpath(  # type: ignore
                '//ul[contains(@class, "download_links")]//a/@href')
        ]
        # self.whatsnew = page.xpath('/html/body/table/tbody/tr/td/table[2]/tbody/tr/td[1]/center[2]/textarea')[0].text_content()
        whatsnew_elem_title = "What's new"
        self.whatsnew = page.xpath(
            f'//center/b[contains(text(), "{whatsnew_elem_title}")]/following::textarea'
        )[0].text  # type: ignore
        log.info('%s', self)

    def __repr__(self) -> str:
        return f'{self.__class__.__name__}({self.name} {self.version})'

    def __str__(self) -> str:
        return f'{self.name} {self.version} ({self.category})\n{self.download_urls}\n{self.whatsnew}'


def download_file(
    url: httpx.URL,
    dest_dir: str,
    progressbar: Optional[progress.Progress],
    httpx_client: Optional[httpx.Client] = None,
) -> Optional[str]:
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
                    continue
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
            return destination


def main() -> NoReturn:
    import argparse
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
            with open(whatsnew_fname_tmp, 'w') as f:
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
                    download_file(
                        url,
                        dest_dir,
                        progressbar,
                        httpx_client=httpx_client,
                    )
                except Exception:
                    log.exception('Failed to download %s', url)

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
