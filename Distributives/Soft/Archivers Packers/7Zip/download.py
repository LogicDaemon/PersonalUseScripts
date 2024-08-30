#!/usr/bin/env python3
from __future__ import annotations, generator_stop

import email.parser
# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import email.utils
import logging
import os
import pathlib
import threading
import time
from datetime import datetime
from dataclasses import dataclass
from typing import Iterable, List, NamedTuple, Optional, Tuple

# Installable modules https://pypi.org/
import httpx
import lxml
import lxml.html
from werkzeug.http import parse_options_header
from werkzeug.utils import secure_filename

try:
    from pip._vendor.rich.progress import Progress
except ImportError:
    from rich.progress import Progress

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


@dataclass(frozen=True)
class Config:
    """ Configuration for the script """
    dest_dir: pathlib.Path
    temp_dir: pathlib.Path
    http2: bool


config: Config


def get_env_log_level(
    default: int = logging.INFO if __debug__ else logging.WARNING
) -> Tuple[int, Optional[str]]:
    """ Get the log level from the environment variable LOG_LEVEL """
    # pylint: disable=R0801,duplicate-code
    try:
        env_log_level = os.environ['LOG_LEVEL']
    except KeyError:
        return default, None
    valid_log_levels = {'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'}
    if env_log_level not in valid_log_levels:
        return default, (f'Invalid log level {env_log_level}, '
                         f'must be one of {", ".join(valid_log_levels)}')
    return getattr(logging, env_log_level.upper()), None


def parse_last_modified(headers: httpx.Headers) -> Optional[float]:
    """ Parse the Last-Modified header """
    try:
        datetime_header = headers['last-modified']
        datetime_header_parsed = email.utils.parsedate(datetime_header)
        assert datetime_header_parsed is not None
        return time.mktime(datetime_header_parsed)
    except (KeyError, ValueError, TypeError, AssertionError):
        return None


class ParseHeadersRV(NamedTuple):
    """ Return value of parse_headers """
    filename: Optional[str]
    last_modified: Optional[float]
    size: Optional[int]


def parse_headers(r: httpx.Response) -> ParseHeadersRV:
    """ Extract values from the headers of the response """

    try:
        content_disp = r.headers['content-disposition']
        filename = parse_options_header(content_disp)[1]['filename']
    except KeyError:
        filename = None

    remote_mtime = parse_last_modified(r.headers)

    try:
        size = int(r.headers['Content-Length'].strip())
    except (KeyError, ValueError):
        size = None

    return ParseHeadersRV(filename, remote_mtime, size)


def build_target_path(filename: str, stem_suffix: str) -> pathlib.Path:
    """ Build the target path for the downloaded file """
    target_path = config.dest_dir / secure_filename(filename)
    target_path = target_path.with_stem(target_path.stem + stem_suffix)
    if len(target_path.name) > 250:
        target_path = target_path.with_stem(
            target_path.stem[:250 - len(target_path.suffix)])

    return target_path


def download_data(r: httpx.Response,
                  original_url: httpx.URL,
                  *,
                  stem_suffix: str = '',
                  progress: Optional[Progress] = None) -> None:
    """ Save the data from the response to a file """
    filename, remote_mtime, size = parse_headers(r)
    target_path = build_target_path(
        filename or pathlib.PurePosixPath(original_url.path).name, stem_suffix)
    del filename, original_url, stem_suffix
    if remote_mtime is not None and target_path.exists():
        mtime = target_path.stat().st_mtime
        if mtime > remote_mtime:
            log.info('Skipping %s, file is newer than on the server',
                     target_path)
            return
        if mtime == remote_mtime:
            if target_path.stat().st_size == size:
                log.info('Skipping %s, file is already downloaded',
                         target_path)
                return
            else:
                bak_name = target_path.with_suffix(
                    f'-{datetime.fromtimestamp(mtime):%Y%m%d%H%M%S}.'
                    f'{target_path.suffix}.bak')
                log.warning(
                    'File %s exists with the same timestamp but different size'
                    '. Renaming to %s', target_path, bak_name)

                target_path.rename(bak_name)

    if progress is not None:
        task = progress.add_task(target_path.name, total=size)
    config.temp_dir.mkdir(parents=True, exist_ok=True)
    tmp_filename = config.temp_dir / target_path.name
    with open(tmp_filename, 'wb') as f:
        for chunk in r.iter_bytes():
            f.write(chunk)
            if progress is not None:
                progress.update(task, advance=len(chunk))
    if progress is not None:
        progress.remove_task(task)
    # update timestamp
    if remote_mtime is not None:
        os.utime(tmp_filename, (time.time(), remote_mtime))
    tmp_filename.replace(target_path)
    log.info('Downloaded %s', target_path)


def download(client: httpx.Client,
             url: httpx.URL,
             *,
             stem_suffix: str = '',
             progress: Optional[Progress] = None) -> None:
    """ Download a file """
    log.info('Downloading %s', url)
    while True:
        with client.stream('GET', url) as r:  # , follow_redirects=True
            if r.is_redirect:
                url = httpx.URL(r.headers['location'])
                continue
            r.raise_for_status()
            return download_data(r,
                                 url,
                                 stem_suffix=stem_suffix,
                                 progress=progress)


def download_7zip() -> None:
    """ Parse the 7-Zip download page, download the files """

    base_url = httpx.URL('https://7-zip.org/')
    with httpx.Client(http2=config.http2) as client:
        r = client.get(base_url)
        r.raise_for_status()
        page = lxml.html.fromstring(r.text)
        # /html/body/table/tbody/tr/td[2]/table/tbody/tr/td[1]/table[1]/tbody/tr
        # <tr>
        # <th class="Title">Link</th>
        # <th class="Title">Type</th>
        # <th class="Title">Windows</th>
        # <th class="Title">Size</th>
        # </tr>
        # <tr>
        # <td class="Item"><a href="a/7z2408-x64.exe">Download</a></td>
        # <td class="Item">.exe</td>
        # <td class="Item">64-bit x64</td>
        # <td class="Item">1.6	 MB</td>
        # </tr>
        ver_tables = page.xpath(
            "//table[tr/th[@class='Title'][1][text()='Link'] "
            "and tr/th[@class='Title'][2][text()='Type'] "
            "and tr/th[@class='Title'][3][text()='Windows'] "
            "and tr/th[@class='Title'][4][text()='Size']]")
        assert isinstance(ver_tables, Iterable)

        with Progress() as progress:
            dl_threads: List[threading.Thread] = []
            for ver_table in ver_tables:
                rows = ver_table.xpath("tr[position()>1]")  # type: ignore
                if not isinstance(rows, Iterable):
                    continue
                for row in rows:
                    columns = row.xpath("td[@class='Item']")  # type: ignore
                    if not isinstance(columns, Iterable) or len(columns) < 4:
                        continue
                    urls = columns[0].xpath("a/@href")  # type: ignore
                    if not isinstance(urls, Iterable) or not urls:
                        continue
                    link: str = urls if isinstance(
                        urls, str) else urls[0]  # type: ignore
                    type_ = columns[1].text_content().strip()  # type: ignore
                    arch = columns[2].text_content().strip()  # type: ignore
                    size = columns[3].text_content().strip()  # type: ignore
                    log.debug('Link: %s, Type: %s, Arch: %s, Size: %s', link,
                              type_, arch, size)
                    t = threading.Thread(target=download,
                                         args=(client, base_url.join(link)),
                                         kwargs={
                                             'stem_suffix': ' ' + arch,
                                             'progress': progress
                                         })
                    t.start()
                    dl_threads.append(t)

        for t in dl_threads:  # to avoid closing the client
            t.join()


def init() -> None:
    """ Initialize the script """
    global config  # pylint: disable=W0603,global-statement
    log_level, err_msg = get_env_log_level()
    try:
        dest_dir = pathlib.Path(os.environ['srcpath'])
    except KeyError:
        dest_dir = pathlib.Path(__file__).resolve().parent
    try:
        temp_dir = pathlib.Path(os.environ['workDir'])
    except KeyError:
        temp_dir = dest_dir / 'temp'
    logs_dir = pathlib.Path(os.environ.get('logsDir', temp_dir))
    logs_dir.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(level=log_level,
                        handlers=[
                            logging.FileHandler(logs_dir / 'download.log'),
                            logging.StreamHandler()
                        ])
    if err_msg:
        log.error(err_msg)

    config = Config(dest_dir=dest_dir, temp_dir=temp_dir, http2=True)


def main() -> None:
    """ Executed when run from the command line """
    # filename_from_content_disposition(
    #     httpx.Headers({
    #         'Content-Disposition':
    #         "attachment; filename*=UTF-8''%E2%82%ACrates.txt"
    #     }))
    # filename_from_content_disposition(
    #     httpx.Headers(
    #         {'Content-Disposition': "attachment; filename=Crates.txt"}))
    init()
    download_7zip()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
