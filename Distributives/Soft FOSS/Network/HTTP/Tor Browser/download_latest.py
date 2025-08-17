#!/usr/bin/env python3
""" Download the latest Tor browser distributive for the current OS """

from __future__ import annotations

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import email.utils
from fnmatch import fnmatch
import logging
import os
import platform
import re
import sys
import time
from typing import Dict, List, NamedTuple
import urllib.parse

# Installable standard modules
import httpx
import lxml.html
import packaging.version
import rich.progress

# https://www.torproject.org/download/:
#   https://www.torproject.org/dist/torbrowser/14.5.5/tor-browser-windows-x86_64-portable-14.5.5.exe
#   https://www.torproject.org/dist/torbrowser/14.5.5/tor-browser-macos-14.5.5.dmg
#   https://www.torproject.org/dist/torbrowser/14.5.5/tor-browser-linux-x86_64-14.5.5.tar.xz
# https://www.torproject.org/download/#android:
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-android-aarch64-14.5.5.apk
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-android-armv7-14.5.5.apk
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-android-x86_64-14.5.5.apk
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-android-x86-14.5.5.apk

# https://www.torproject.org/download/languages/:
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-windows-i686-portable-14.5.5.exe
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-windows-i686-portable-14.5.5.exe.asc
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-windows-x86_64-portable-14.5.5.exe
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-windows-x86_64-portable-14.5.5.exe.asc
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-macos-14.5.5.dmg
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-macos-14.5.5.dmg.asc
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-i686-14.5.5.tar.xz
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-i686-14.5.5.tar.xz.asc
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-x86_64-14.5.5.tar.xz
#   https://dist.torproject.org/torbrowser/14.5.5/tor-browser-linux-x86_64-14.5.5.tar.xz.asc

# Select table cell by column name
# https://stackoverflow.com/a/14807253/1421036
# a[contains(@class, "downloadLink")] is only for 32-bit link unfortunately


class PlatformDownload(NamedTuple):
    page_url: str
    xpath: str
    name_mask: str


PLATFORM_DOWNLOADS: Dict[str, PlatformDownload] = {
    'Windows32bit':
    PlatformDownload(
        'https://www.torproject.org/download/languages/',
        '//table//td[count(//table//thead//th[normalize-space()="Windows"]/preceding-sibling::th)+1]//a[text()="32-bit"]',
        '*-windows-i686-*.exe'),
    'Windows64bit':
    PlatformDownload(
        'https://www.torproject.org/download/',
        '//table/tbody/tr/td[count(//table/thead/tr/th[normalize-space()="Windows"]/preceding-sibling::th)+1]/a[text()="64-bit"]',
        '*-windows-x86_64-*.exe'),
    'Darwin':
    PlatformDownload(
        'https://www.torproject.org/download/',
        '//table/tbody/tr/td[count(//table/thead/tr/th[normalize-space()="macOS"]/preceding-sibling::th)+1]/a[1]',
        '*.dmg'),
    'Linux32bit':
    PlatformDownload(
        'https://www.torproject.org/download/languages/',
        '//table//td[count(//table//thead//th[normalize-space()="GNU/Linux"]/preceding-sibling::th)+1]//a[text()="32-bit"]',
        '*-linux-i686-*'),
    'Linux64bit':
    PlatformDownload(
        'https://www.torproject.org/download/',
        '//table/tbody/tr/td[count(//table/thead/tr/th[normalize-space()="GNU/Linux"]/preceding-sibling::th)+1]/a[text()="64-bit"]',
        '*-linux-x86_64-*'),
}

# PLATFORMS_FILENAME_MASKS_UP_TO_V12 = {
#     'Windows32bit': 'torbrowser-install-{version}_ALL.exe',
#     'Windows64bit': 'torbrowser-install-win64-{version}_ALL.exe',
#     'Darwin': 'TorBrowser-{version}-macos_ALL.dmg',
#     'Linux32bit': 'tor-browser-linux32-{version}_ALL.tar.xz',
#     'Linux64bit': 'tor-browser-linux64-{version}_ALL.tar.xz',
# }

client = httpx.Client(http2=True, follow_redirects=True)


def list_web_files(url: str) -> List[str]:
    out: List[str] = []
    response = client.get(url + '?F=0')
    response.raise_for_status()
    dlpage = lxml.html.fromstring(response.text)
    assert isinstance(dlpage, lxml.html.HtmlElement)  # type: ignore
    for link in dlpage.xpath('/html/body/ul/li[*]/a'):
        if re.sub(r'\W', '', link.text).lower() == 'parentdirectory':
            continue
        out.append(link.attrib['href'])  # type: ignore
    return out


def get_downloads_page_link(v: PlatformDownload) -> List[str]:
    links = []
    response = client.get(v.page_url)
    response.raise_for_status()
    dlpage = lxml.html.fromstring(response.text)
    assert isinstance(dlpage, lxml.html.HtmlElement)  # type: ignore

    # find the link to the latest version
    for dl_a in dlpage.xpath(v.xpath):
        assert isinstance(dl_a, lxml.html.HtmlElement)  # type: ignore
        url = dl_a.attrib['href']
        if fnmatch(os.path.basename(urllib.parse.urlparse(url).path),
                   v.name_mask):
            logging.info('Found %s on %s with URL %s', dl_a.text, v.page_url,
                         url)
            links.append(urllib.parse.urljoin(v.page_url, url))
    return links


def find_files_on_page(url: str, filename_mask: str) -> List[str]:
    """Find a file on a web page by its name mask"""
    out: List[str] = []
    for href in list_web_files(url):
        if fnmatch(href, filename_mask):
            out.append(urllib.parse.urljoin(url, href))
    return out


def download_file(dist_url: str) -> None:
    destination = os.path.basename(dist_url)
    destination_tmp = destination + '.tmp'
    logging.info('Downloading %s', dist_url)
    with client.stream("GET", dist_url) as dl:
        dl.raise_for_status()
        last_modified = email.utils.parsedate(dl.headers['last-modified'])

        # check that currently downloaded file is not the same as on the server
        if last_modified and os.path.exists(destination):
            if abs(os.path.getmtime(destination) - time.mktime(last_modified)
                   ) < 60:  # 1 minute difference is ok
                logging.info('File %s is already up-to-date', destination)
                return

        with rich.progress.Progress(
                rich.progress.DownloadColumn(),
                rich.progress.BarColumn(),
                rich.progress.TextColumn(
                    "[progress.percentage]{task.percentage:>3.0f}%"),
                rich.progress.TimeRemainingColumn(),
        ) as progress:
            task_id = progress.add_task("Downloading",
                                        total=int(
                                            dl.headers['Content-Length']))
            with open(destination_tmp, 'wb') as f:
                for chunk in dl.iter_bytes():
                    f.write(chunk)
                    progress.update(task_id, advance=len(chunk))
        if last_modified:
            os.utime(destination_tmp,
                     (time.time(), time.mktime(last_modified)))
        os.replace(destination_tmp, destination)


def find_in_the_directory(platform_download: PlatformDownload,
                          find_alpha: bool = False) -> List[str]:
    """ Both current release and alphas are available at
        https://dist.torproject.org/torbrowser/
    """
    # https://packaging.python.org/en/latest/specifications/version-specifiers/
    latest_version = packaging.version.Version('0')
    for subdir in list_web_files('https://dist.torproject.org/torbrowser/'):
        if not subdir.endswith('/'):
            continue
        version = packaging.version.parse(subdir.rstrip('/'))
        if version > latest_version and (find_alpha or
                                         ('a' not in subdir
                                          and 'b' not in subdir)):
            latest_version = version
            latest_subdir = subdir

    if latest_version is None:
        logging.error(
            'Failed to find a matching version in https://dist.torproject.org/torbrowser/'
        )
        return []
    return find_files_on_page(
        'https://dist.torproject.org/torbrowser/' + latest_subdir,
        platform_download.name_mask)


def main() -> None:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--debug',
        '-d',
        action='store_true',
        help='Debug mode',
    )
    parser.add_argument(
        '--alpha',
        '-a',
        action='store_true',
        help='Enable downloading pre-release (alpha/beta) versions',
    )

    # 'Linux', 'Darwin', 'Java', 'Windows', 'iOS, 'iPadOS', 'Android'
    platform_system = platform.system()
    default_platform = (platform_system if platform_system
                        in PLATFORM_DOWNLOADS else platform_system +
                        platform.architecture()[0])

    parser.add_argument(
        '--platform',
        '-t',
        choices=PLATFORM_DOWNLOADS.keys(),
        help=f'Platform to download for (default: {default_platform})',
    )
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    if args.platform is None:
        args.platform = default_platform

    platform_download = PLATFORM_DOWNLOADS.get(args.platform)
    dist_urls = (None if platform_download is None or args.alpha else
                 get_downloads_page_link(platform_download)
                 or find_in_the_directory(platform_download, args.alpha))

    if not dist_urls:
        logging.error('Failed to find a distributive for %s', args.platform)
        sys.exit(1)

    for dist_url in dist_urls:
        return download_file(dist_url)


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
