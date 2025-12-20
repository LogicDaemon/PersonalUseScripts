#!/usr/bin/env python3
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
from collections import deque
import importlib
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
import tempfile
import threading
from typing import (
    Any,
    Deque,
    Iterable,
    List,
    Optional,
    Tuple,
    Union,
)


def import_with_install(
        imports: Iterable[Union[str, Tuple[str, str]]]) -> None:
    """ Import modules, installing them if they are not available """
    modules_tmp = None
    for module in imports:
        module, modulepipname = module if isinstance(
            module, tuple) else (module, module)
        try:
            globals()[module] = importlib.import_module(module)
        except ImportError:
            if modules_tmp is None:
                import subprocess
                modules_tmp = os.path.join(tempfile.gettempdir(),
                                           'distdownload_modules')
                sys.path.insert(0, modules_tmp)
            subprocess.check_call([
                sys.executable, '-m', 'pip', 'install', '--target',
                modules_tmp, modulepipname
            ])
            globals()[module] = importlib.import_module(module)


import_with_install([
    ('httpx', 'httpx[http2]'),
    ('werkzeug'),
    ('bs4', 'beautifulsoup4'),
])
# Actual imports happen above; these ones are for type checking
# Installable modules https://pypi.org/
import httpx  # httpx[http2]  # NOQA: E402
import werkzeug.http  # NOQA: E402
import werkzeug.utils  # werkzeug  # NOQA: E402
from bs4 import BeautifulSoup  # beautifulsoup4  # NOQA: E402

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def extract_download_urls(soup: BeautifulSoup) -> list[str]:
    """Extract direct download URLs from the specific table on the page.

    Strategy:
    1. Identify the table that contains headers: Type:, Location:, Hosted By:
       (They are inside <b> tags in the first row.)
    2. Collect all <a href> elements in subsequent rows whose text matches
       "Server" (e.g., "Server 1", "Server 2"), ignoring external links
       (which contain 'majorgeeks' and have target="_blank").
    3. Return list of absolute URLs.

    Robustness:
    - If the precise header match fails, fall back to scanning all tables
      for ones having at least two <a> tags whose href contains
      'K-Lite_Codec_Pack' and ends with '.exe'.
    - No network activity is performed here; purely parsing.
    """
    # <table border="0" cellspacing="0" cellpadding="2"><tbody><tr>
    # <td width="50"><b>Type:</b></td>
    # <td width="140"><b>Location:</b></td>
    # <td width="150"><b>Hosted By:</b></td></tr>
    # <tr>
    # <td>HTTPS</td>
    # <td><a href="https://files2.codecguide.com/K-Lite_Codec_Pack_1930_Standard.exe">Server 1</a></td>
    # <td>Codec Guide</td></tr>
    # <tr><td>HTTPS</td>
    # <td><a href="https://files3.codecguide.com/K-Lite_Codec_Pack_1930_Standard.exe">Server 2</a></td>
    # <td>Codec Guide</td></tr><tr>
    # <td>HTTPS</td>
    # <td><a href="https://www.majorgeeks.com/files/details/k_lite_codec_pack_standard.html" target="_blank">Server 3</a> (external)</td>
    # <td>MajorGeeks</td></tr></tbody></table>
    # First try: find table with the expected three header <b> tags
    candidate_tables: list[Any] = []
    for table in soup.find_all('table'):
        bolds = [b.get_text(strip=True) for b in table.find_all('b')]
        header_set = {t.rstrip(':') for t in bolds}
        if {'Type', 'Location', 'Hosted By'} <= header_set:
            candidate_tables.append(table)

    urls: list[str] = []
    for table in candidate_tables:
        for a in table.find_all('a'):
            href = a.get('href')
            if not href:
                continue
            text = a.get_text(strip=True)
            if not text.lower().startswith('server'):
                continue
            # Skip known external mirror description links (e.g. majorgeeks page)
            if 'majorgeeks' in href.lower():
                continue
            if href.startswith('http://') or href.startswith('https://'):
                urls.append(href)
    if urls:
        # Deduplicate while preserving order
        seen = set()
        uniq: list[str] = []
        for u in urls:
            if u not in seen:
                seen.add(u)
                uniq.append(u)
        return uniq

    # Fallback: scan all anchors for probable installer links
    return fallback_exe_links(soup)


def fallback_exe_links(soup: BeautifulSoup) -> list[str]:
    """Fallback heuristic to find .exe links referencing K-Lite codec pack.

    Looks for <a> tags whose href contains 'K-Lite_Codec_Pack' (case-insensitive)
    and ends with '.exe'. Returns deduplicated list.
    """
    matches: list[str] = []
    for a in soup.find_all('a'):
        href = a.get('href')
        if not href:
            continue
        href_lower = href.lower()
        if 'k-lite_codec_pack' in href_lower and href_lower.endswith('.exe'):
            if href.startswith('http://') or href.startswith('https://'):
                matches.append(href)
    seen: set[str] = set()
    uniq: list[str] = []
    for u in matches:
        if u not in seen:
            seen.add(u)
            uniq.append(u)
    return uniq


def writer(filename: Union[str, os.PathLike], buffer: Deque[bytes],
           writing: threading.Event, done: threading.Event) -> None:
    """ Write the buffered data to the file """
    with open(filename, 'wb') as f:
        while not done.is_set() or writing.is_set() or buffer:
            while buffer:
                f.write(buffer.popleft())
            writing.clear()
            writing.wait(1)


def write_streamed_file(r: httpx.Response,
                        local_filename: Path) -> Tuple[Path, threading.Thread]:
    """ Write the streamed response to a file in a separate thread """
    tempf = local_filename.parent / 'temp' / local_filename.name
    tempf.parent.mkdir(parents=True, exist_ok=True)

    buffer: Deque[bytes] = deque()
    writing = threading.Event()
    done = threading.Event()
    writer_thread = threading.Thread(target=writer,
                                     args=(tempf, buffer, writing, done))
    writer_thread.start()
    for chunk in r.iter_bytes(chunk_size=65536):
        buffer.append(chunk)
        writing.set()
    done.set()
    return tempf, writer_thread


def download(cl: httpx.Client,
             url: httpx.URL,
             out_dir: Path,
             max_time_diff: float = 2 * 60 * 60) -> List[Path]:
    with cl.stream('GET', url) as r:
        r.raise_for_status()
        log.debug('%s', r.headers)
        content_disp = r.headers.get('content-disposition')
        local_filename = (out_dir / werkzeug.utils.secure_filename(
            werkzeug.http.parse_options_header(content_disp)[1]['filename']
            if content_disp is not None else os.path.basename(url.path)))
        last_modified = werkzeug.http.parse_date(
            r.headers.get('last-modified'))
        if last_modified:
            log.info('Remote file "%s" modified %s', local_filename,
                     last_modified)
            last_modified_ts = last_modified.timestamp()
            if os.path.exists(local_filename):
                current_time = os.path.getmtime(local_filename)
                # different mirrors have different timestamps for some reason, f.e.
                # https://files2.codecguide.com/K-Lite_Codec_Pack_1935_Standard.exe 2025-12-04 18:48:17+00:00
                # https://files3.codecguide.com/K-Lite_Codec_Pack_1935_Standard.exe 2025-12-04 19:23:18+00:00
                if abs(current_time - last_modified_ts) < max_time_diff:
                    log.info('Remote file "%s" is up to date', local_filename)
                    return []
                log.warning(
                    'Local file "%s" exists but timestamp differs: '
                    'local %s, remote %s', local_filename,
                    datetime.fromtimestamp(current_time),
                    datetime.fromtimestamp(last_modified_ts))
        else:
            log.warning('Last-modified header is missing for %s', r.url)
            last_modified_ts = None

        tempf, writer_thread = write_streamed_file(r, local_filename)
    writer_thread.join()
    if last_modified_ts is not None:
        os.utime(tempf, (last_modified_ts, last_modified_ts))
    os.replace(tempf, local_filename)
    return [local_filename]


def guess_dist_base(out_dir: Path) -> Optional[Path]:
    """ Guess the base directory for distributives based on the output directory
        and the current working directory.
    """
    out_dir = out_dir.absolute()
    for d in reversed(out_dir.parents[:-1]):
        dn_low = d.name.lower()
        if dn_low.startswith('dist'):
            return d
        if dn_low.startswith('soft'):
            return d.parent
    return None


def cleanup(out_dir: Path, do_not_delete_files: Iterable[Path]) -> None:
    """ Cleanup the files matching the dist_mask in the out_dir.
        There are three actions:
        * 'echo' - just print the paths of the files that would be deleted,
        * 'move' - move the files to the archive_dir, preserving the relative
          path after root_dir,
        * 'delete' - delete the files.

        The files that should not be deleted are specified in the
        do_not_delete_files argument, which is a list of Path objects.
        
        If the config.dist_mask is set, it is used to find the files to delete.

        If the config.dist_mask is not set, the files are read from the
        the list which is updated when the function is called,
        and all the files listed there are removed except the ones in
        do_not_delete_files of the current call.

        The list is stored in the config.out_dir with the name
        _DistDownload.py.list.
    """
    keep_files = set(str(v.relative_to(out_dir)) for v in do_not_delete_files)
    list_path = (out_dir / os.path.basename(__file__)).with_suffix('.list')

    try:
        cleanup_list = set(list_path.read_text().strip().splitlines())
    except FileNotFoundError:
        cleanup_list = set()

    # Remove the files that should not be deleted
    cleanup_list -= keep_files
    # If the dist_mask is not set, update the list file
    # with the files that should not be deleted now
    # (they will be removed on the next call)
    list_path.write_text('\n'.join(cleanup_list | keep_files) + '\n')

    root_dir_str = os.getenv('baseDistributives')
    root_dir = Path(root_dir_str) if root_dir_str else guess_dist_base(out_dir)
    if root_dir is None:
        # just delete the files
        for i in cleanup_list:
            src = out_dir / i
            if src.is_file():
                log.info('Deleting %s', src)
                os.remove(src)
    else:
        # move the files to the archive_dir
        archive_root = root_dir / '_old'
        archive_dir = archive_root / out_dir.relative_to(root_dir)
        for i in cleanup_list:
            src = out_dir / i
            if src.is_file():
                dest = archive_dir / i
                dest.parent.mkdir(parents=True, exist_ok=True)
                log.info('Moving %s to %s', src, dest)
                os.replace(src, dest)


def main() -> None:
    """ Executed when run from the command line """
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s:' + logging.BASIC_FORMAT,
                        datefmt='%Y-%m-%dT%H:%M:%S')
    # curl 'https://codecguide.com/download_k-lite_codec_pack_standard.htm' \
    #   -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    #   -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8,ru;q=0.7,ka;q=0.6' \
    #   -H 'cache-control: max-age=0' \
    #   -H 'if-modified-since: Fri, 31 Oct 2025 19:13:16 GMT' \
    #   -H 'if-none-match: "69050a4c-261c"' \
    #   -H 'priority: u=0, i' \
    with httpx.Client(http2=True) as client:
        r = client.get(
            'https://codecguide.com/download_k-lite_codec_pack_standard.htm',
            headers={'Referer': 'https://codecguide.com/download_kl.htm'})
        log.debug('Response headers: %s', r.headers)
        r.raise_for_status()
        data = r.text
        soup = BeautifulSoup(data, 'html.parser')
        urls = extract_download_urls(soup)
        if not urls:
            log.warning('No download URLs found in expected table; '
                        'attempting fallback pattern search.')
            urls = fallback_exe_links(soup)
        if not urls:
            log.error('No download URLs found.')
            sys.exit(1)
        for url in urls:
            log.info('Downloading %s', url)
            files = download(client, httpx.URL(url), out_dir=Path.cwd())
            if files:
                break
        else:
            log.error('All download attempts failed.')
            sys.exit(1)
        cleanup(Path.cwd(), files)


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
