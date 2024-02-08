#!/usr/bin/env python3
""" Download emails from an IMAP server,
    and save them to a directory,
    optionally delete them from the server.
"""
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import dataclasses
import getpass
import logging
import os
import sys
import imaplib
from dataclasses import field as dc_field
from typing import (Any, Dict, Generator, Iterable, List, NoReturn, Optional,
                    Tuple, Type, TypedDict, Union, cast)

# Installable modules https://pypi.org/
import yaml

UTF8_ENCODING_NAME = 'utf8'

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(
    default=logging.DEBUG if __debug__ else logging.INFO
) -> Tuple[int, Optional[str]]:
    ''' Get the log level from the environment variable LOG_LEVEL '''
    # pylint: disable=R0801,duplicate-code
    env_log_level = os.environ.get('LOG_LEVEL')
    valid_log_levels = {'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'}
    if env_log_level not in valid_log_levels:
        return default, (f'Invalid log level {env_log_level}, '
                         f'must be one of {', '.join(valid_log_levels)}')
    return getattr(logging, env_log_level.upper()), None


def config_paths() -> Generator[str, None, None]:
    # pylint: disable=R0801,duplicate-code,C0415,import-outside-toplevel  # NOQA: E501
    import appdirs
    name_wo_ext = os.path.splitext(__file__)[0]
    yield name_wo_ext + '.yml'
    basename = os.path.basename(name_wo_ext)
    yield os.path.join(appdirs.user_config_dir(basename), 'config.yml')
    yield (os.path.join(appdirs.site_config_dir(basename), 'config.yml')
           if appdirs.system in {'win32', 'darwin'} else os.path.join(
               '/etc', basename + '.config.yml'))


class CustomHelpAction(argparse.Action):

    def __call__(self,
                 parser,
                 namespace,
                 values,
                 option_string=None) -> NoReturn:
        # Call your function here
        parser.print_help()
        print('Configuration is loaded from the first of following files:')
        for path in config_paths():
            print(f'  {path}')
        parser.exit()


ConfigOption = TypedDict('ConfigOption', {
    'action': Union[str, Type[argparse.Action]],
    'default': Any,
    'help': str,
    'short_name': str,
    'required': bool,
    'type': Any,
    'nargs': int,
},
                         total=False)


# Use @dataclasses.dataclass(slots=True) after upgrading to python 3.10
# https://stackoverflow.com/a/69661861/1421036
@dataclasses.dataclass(**({} if sys.version_info < (3, 10) else {
    'slots': True
}))  # pylint: disable=unexpected-keyword-arg  # NOQA: E501
class Config:
    # pylint: disable=R0801,duplicate-code,R0902,too-many-instance-attributes  # NOQA: E501
    username: str = dc_field(
        metadata=ConfigOption(help='Username', short_name='u'))
    password: str = dc_field(metadata=ConfigOption(
        help='Password. If not defined, read from stdin.', short_name='p'))
    imap_server: str = dc_field(
        metadata=ConfigOption(help='IMAP server', short_name='s'))
    server_response_encoding: str = dc_field(metadata=ConfigOption(
        default=UTF8_ENCODING_NAME, help='Server response encoding'))
    mailbox: str = dc_field(metadata=ConfigOption(
        default='INBOX', help='Mailbox (folder) name', short_name='m'))
    filter: str = dc_field(metadata=ConfigOption(
        default='ALL', help='Filter for the emails', short_name='f'))
    path: str = dc_field(metadata=ConfigOption(
        default='emails', help='Target directory path', short_name='t'))
    delete: bool = dc_field(metadata=ConfigOption(
        action='store_true', help='Delete emails from server'))
    debug: str = dc_field(metadata=ConfigOption(
        action='store_true', help='Debug mode', short_name='d'))

    def __init__(self) -> None:
        self.load()

    @staticmethod
    def _load_file(path: Union[str, os.PathLike]) -> Dict:
        with open(path) as f:
            return yaml.safe_load(f)

    def load(
        self,
        paths: Union[None, str, Iterable[str], Iterable[os.PathLike]] = None
    ) -> None:
        if paths is None:
            paths = config_paths()
        elif isinstance(paths, str):
            paths = [paths]
        for path in paths:
            try:
                data = self._load_file(path)
            except FileNotFoundError:
                continue
            break
        else:
            return
        available_options = frozenset(
            [k.name for k in dataclasses.fields(self)])
        for option, value in data.items():
            if option not in available_options:
                raise ValueError(f'Unknown option {option}')
            setattr(self, option, value)

    def argparse_args(
            self) -> Generator[Tuple[List[str], ConfigOption], None, None]:
        yield (['--help', '-h', '-?'],
               ConfigOption(action=CustomHelpAction,
                            help='Show this help message and exit',
                            nargs=0))
        for conf_field in dataclasses.fields(self):
            option = cast(ConfigOption, conf_field.metadata)
            name = conf_field.name.replace('_', '-')
            parser_kwargs: ConfigOption = option.copy()
            if hasattr(self, conf_field.name):
                # a value is already loaded from the config file
                parser_kwargs.pop('default', None)
            elif ('default' not in parser_kwargs
                  and conf_field.default is not dataclasses.MISSING):
                parser_kwargs['default'] = conf_field.default
            short_name = parser_kwargs.pop('short_name', None)
            parser_args = ([f'--{name}'] +
                           ([] if short_name is None else [f'-{short_name}']))
            yield parser_args, parser_kwargs

    def argument_parser(self) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            add_help=False)
        for parser_args, parser_kwargs in self.argparse_args():
            parser.add_argument(*parser_args, **parser_kwargs)
        return parser

    def apply_args(self,
                   args: argparse.Namespace,
                   logging_force_reconfig: bool = False) -> None:
        for conf_field in dataclasses.fields(self):
            name = conf_field.name.replace('-', '_')
            new_value = getattr(args, name)
            if new_value is not None or not hasattr(self, name):
                setattr(self, name, getattr(args, name))

        if self.debug:
            log_level, env_log_level_error = logging.DEBUG, None
        else:
            log_level, env_log_level_error = get_env_log_level()
        logging.StreamHandler.terminator = ""
        logging.basicConfig(level=log_level, force=logging_force_reconfig)
        if env_log_level_error is not None:
            log.warning('%s\n', env_log_level_error)

    def process_cli(self) -> argparse.Namespace:
        args = self.argument_parser().parse_args()
        self.apply_args(args)
        return args


def log_imap4_response(resp: Iterable[bytes | None], enc: str) -> None:
    if log.isEnabledFor(logging.DEBUG):
        for i in resp:
            if i:
                try:
                    log.debug('> %s\n', i.decode(enc))
                except UnicodeDecodeError:
                    log.debug('> %s\n', i)


def main() -> None:
    # pylint: disable=R0801,duplicate-code  # NOQA: E501
    config.process_cli()
    dest_dir = config.path
    if not os.path.isdir(dest_dir):
        os.makedirs(dest_dir)
    if config.password is None:
        config.password = getpass.getpass('Password: ')
    enc = config.server_response_encoding

    imapi_client = imaplib.IMAP4_SSL(config.imap_server)
    log.debug('IMAPI client: %s\nLogging in... ', imapi_client)
    typ, resp = imapi_client.login(config.username, config.password)

    log.debug('%s\n', typ)
    log_imap4_response(resp, enc)
    log.info('Selecting mailbox %s... ', config.mailbox)
    typ, msg_count_b = imapi_client.select(config.mailbox)
    if msg_count_b and msg_count_b[0] is not None:
        msg_count = (
            f', {msg_count_b[0].decode(enc)} messages'  # pyright: ignore[reportOptionalMemberAccess]  # NOQA: E501
        )
    else:
        msg_count = ''
    log.info('%s%s\n', typ, msg_count)
    if len(msg_count_b) > 1:
        log_imap4_response(msg_count_b[1:], enc)
    log.debug('Searching for %s... ', config.filter)
    typ, msg_ids = imapi_client.search(
        None if enc == UTF8_ENCODING_NAME else enc, config.filter)
    log.debug('%s %s\n', typ, msg_ids)
    d: bytes
    for d in msg_ids:
        try:
            decoded_ids = d.decode(enc)
        except UnicodeDecodeError:
            log.error('Failed to decode message IDs, response: %s', d)
            continue
        for num in decoded_ids.split():
            log.debug('Fetching message %s... ', num)
            typ, msg_data = imapi_client.fetch(num, '(RFC822)')
            log.debug('%s\n', typ)
            for response_part in msg_data:
                if isinstance(response_part, tuple):
                    if log.isEnabledFor(logging.DEBUG):
                        log.debug('... part %s\n', response_part[1])
                    with open(os.path.join(dest_dir, f'{num}.eml'), 'wb') as f:
                        f.write(response_part[1])
                else:
                    log.debug('Unsupported response:\n> %s\n', response_part)
            if config.delete:
                log.info('Deleting message %s... ', num)
                typ, response = imapi_client.store(num, '+FLAGS', r'\Deleted')
                log.debug('%s\n', typ)
                log_imap4_response(response, enc)
    if config.delete:
        log.info('Expunging mailbox... ')
        typ, response = imapi_client.expunge()
        log.debug('%s\n', typ)
        log_imap4_response(response, enc)
    log.info('Done.')


config = Config()

if __name__ == '__main__':
    # This is executed when run from the command line
    main()
