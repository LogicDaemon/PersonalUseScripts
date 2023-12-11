#!/usr/bin/env python3
""" Removes a range of Jenkins builds. """

from __future__ import annotations, generator_stop

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import (Optional, NoReturn)
import sys
import os
import logging
#import configparser

# Installable modules, see https://pypi.org/
import gevent
import gevent.monkey

gevent.monkey.patch_all()

import httpx

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def delete_build(client: httpx.Client,
                 base_url: str,
                 auth: httpx.BasicAuth,
                 force: bool = False) -> None:
    while True:
        url = f'{base_url}/doDelete'
        log.info('Posting %s', url)
        r = client.post(url, auth=auth)
        if r.status_code in (200, 302):
            log.info('Response: %s', r)
            break
        log.error('Error %r deleting %s', r, base_url)
        if r.status_code != 400 or not force:  # 400 Bad Request - Build is not deletable
            break
        force = False  # Try only once to remove the mark to keep the build forever
        log.info('Trying to remove the mark to keep the build %s forever',
                 base_url)
        r = client.post(f'{base_url}/toggleLogKeep', auth=auth)
        log.info('Response: %s', r)
        if r.status_code not in (200, 302):
            log.error(
                'Error %s removing the mark to keep the build forever: %s', r,
                base_url)
            break


def main() -> NoReturn:
    default_cred_path = os.path.join(
        os.environ.get('SecretDataDir') or os.path.join(
        os.environ.get('LOCALAPPDATA', os.environ.get('HOME', '.')), '_sec'),
        'jenkins-api-credentials.txt')

    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        'base_url',
        help='Base URL for of jenkins build, for example, https://build.anymeeting.com/job/AM_Media/job/Update%20ASGs%20with%20a%20custom%20am_heartbeat/'
    )
    parser.add_argument(
        'range', help='Range of builds numbers to delete, for example, 100-200')
    parser.add_argument(
        '--force',
        '-f',
        action='store_true',
        help='Try removing the mark to keep the build forever if deletion fails'
    )
    parser.add_argument(
        '--credentials',
        '-c',
        default=default_cred_path,
        help='Path to a plaintext file with jenkins credentials, in format user:password. Default: %(default)s'
    )
    parser.add_argument('--debug', '-d', action='store_true', help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(level=logging.DEBUG if args.debug else logging.INFO)

    base_url = args.base_url.rstrip('/')

    if '-' in args.range:
        start, end = args.range.split('-')
        start, end = int(start), int(end)
    else:
        start = end = int(args.range)

    with open(args.credentials) as f:
        cred = f.readline().rstrip('\r\n')
        auth = httpx.BasicAuth(*cred.split(':'))

    with httpx.Client() as client:
        log.info('Deleting builds %d-%d', start, end)
        threads = [
            gevent.spawn(
                delete_build,
                client,
                f'{base_url}/{i}',
                auth=auth,
                force=args.force) for i in range(start, end + 1)
        ]
        # post_thread(client, url=f'{base_url}/{i}/doDelete', auth=auth)
        gevent.joinall(threads)

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
