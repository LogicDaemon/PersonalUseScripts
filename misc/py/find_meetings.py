#!/usr/bin/env -S python3 -O
'''
Get the current user's meetings from https://api.anymeeting.com/
'''

from __future__ import annotations, generator_stop
import json

# Python Standard Library modules, see https://docs.python.org/3/py-modindex.html
from typing import (Optional, NoReturn, cast)
import sys
import os
import logging

# Installable modules, see https://pypi.org/
import win32api
import win32net
import httpx

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(
        default=logging.DEBUG if __debug__ else logging.INFO) -> int:
    ''' Get the log level from the environment variable LOG_LEVEL '''
    env_log_level = os.environ.get('LOG_LEVEL')
    if env_log_level not in ('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'):
        return default
    return getattr(logging, env_log_level.upper())


def user_from_unite_settings() -> str:
    unite_storage_path = os.path.join(os.environ['APPDATA'],
                                      'Intermedia Unite', 'storage')
    with open(unite_storage_path, "r") as f:
        data = json.load(f)
    for elem in data:
        assert isinstance(elem, list)
        if elem[0] == "applicationToken":
            token_data = json.loads(elem[1])['claims']
            for kn in [
                    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn',
                    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
                    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
            ]:
                log.debug('Looking for %s', kn)
                try:
                    username = token_data[kn]
                    return username
                except KeyError:
                    pass
    raise ValueError('Failed to find user id in Unite settings')


def get_am_user_name():
    ''' Get the user email on Windows
    '''
    try:
        return user_from_unite_settings()
    except Exception as e:
        log.warning('%s: %s', e.__class__.__name__, e, exc_info=True)
    return win32net.NetUserGetInfo(win32net.NetGetAnyDCName(),
                                   win32api.GetUserName(), 2)


def main() -> NoReturn:
    import argparse
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--username',
                        '-u',
                        type=str,
                        default=get_am_user_name(),
                        help='Anymeeting username')
    parser.add_argument('--api-base-url',
                        type=httpx.URL,
                        default=httpx.URL('https://api.anymeeting.com/'))
    parser.add_argument('--http-timeout',
                        type=float,
                        default=10,
                        help='HTTP timeout in seconds')
    parser.add_argument('--debug',
                        '-d',
                        action='store_true',
                        help='Debug mode')
    args = parser.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.debug else get_env_log_level())

    api_url: httpx.URL = args.api_base_url

    log.debug('Getting token for %s', args.username)
    with httpx.Client(http2=True,
                      timeout=args.http_timeout,
                      follow_redirects=True) as client:
        token_request_url = api_url.copy_with(
            path='/api/v1/user/login-info').copy_add_param(
                'email', args.username)
        response = client.get(token_request_url)
        log.debug('%s\n%s', response.headers, response.text)

    sys.exit()


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
