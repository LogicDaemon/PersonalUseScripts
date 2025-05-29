#!/usr/bin/env python3
"""
Check if the domain records are up to date;
if not, update them.
"""
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import atexit
import dataclasses
import logging
import os
import pathlib
import sys
import time
from dataclasses import field as dc_field
from typing import (Any, Dict, Generator, Iterable, List, Mapping, NoReturn,
                    Optional, Tuple, Type, TypedDict, Union, cast)

# Installable modules https://pypi.org/
import appdirs
import dns.resolver
import yaml  # pyyaml
import INWX.Domrobot  # type: ignore

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(default: int = logging.INFO) -> Tuple[int, Optional[str]]:
    """ Get the log level from the environment variable LOG_LEVEL """
    # pylint: disable=R0801,duplicate-code
    if os.getenv('DEBUG'):
        return logging.DEBUG, None
    try:
        env_log_level = os.environ['LOG_LEVEL']
    except KeyError:
        return default, None
    valid_log_levels = {'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'}
    if env_log_level not in valid_log_levels:
        return default, (f'Invalid log level {env_log_level}, '
                         f'must be one of {", ".join(valid_log_levels)}')
    return getattr(logging, env_log_level.upper()), None


def config_paths() -> Generator[str, None, None]:
    """ Generate the paths where the configuration file can be found """
    # pylint: disable=R0801,duplicate-code
    name_wo_ext = os.path.splitext(__file__)[0]
    yield name_wo_ext + '.yml'
    basename = os.path.basename(name_wo_ext)
    yield os.path.join(appdirs.user_config_dir(basename), 'config.yml')
    yield (os.path.join(appdirs.site_config_dir(basename), 'config.yml')
           if appdirs.system in {'win32', 'darwin'} else os.path.join(
               '/etc', basename + '.config.yml'))


class CustomHelpAction(argparse.Action):
    """ Custom action to print the help message and the configuration file
        paths
    """

    def __call__(self,
                 parser,
                 namespace,
                 values,
                 option_string=None) -> NoReturn:
        parser.print_help()
        print('Configuration is loaded from the first of following files:')
        for path in config_paths():
            print('  ' + path)
        parser.exit()
        assert False, 'unreachable'


ConfigOption = TypedDict(
    'ConfigOption', {
        'action': Union[str, Type[argparse.Action]],
        'default': Any,
        'help': str,
        'short_name': str,
        'required': bool,
        'type': Type,
        'nargs': int,
    },
    total=False)


# Use @dataclasses.dataclass(slots=True) after upgrading to python 3.10
# https://stackoverflow.com/a/69661861/1421036
@dataclasses.dataclass(**({} if sys.version_info < (3, 10) else {
    'slots': True
}))  # pylint: disable=unexpected-keyword-arg  # NOQA: E501
class Config:
    """ Script parameters class, all parameters can be loaded from a YAML file,
        and overridden from the command line.
    """
    # pylint: disable=R0801,duplicate-code,R0902,too-many-instance-attributes  # NOQA: E501
    domains_config_file_path: pathlib.Path = dc_field(
        metadata=ConfigOption(
            default=pathlib.Path(__file__).parent / 'domains.yml',
            help='Path to the yamls domains configuration file',
            short_name='c'))
    inwx_auth_file_path: pathlib.Path = dc_field(
        metadata=ConfigOption(
            default=pathlib.Path(appdirs.user_config_dir()) / '_sec' /
            'inwx_auth.yml',
            help='Path to the INWX authentication configuration file',
            short_name='x'))
    debug: bool = dc_field(
        metadata=ConfigOption(
            action='store_true', help='Debug mode', short_name='d'))

    def __init__(self) -> None:
        self.load()

    @staticmethod
    def _load_file(path: Union[str, os.PathLike]) -> Dict:
        with open(path) as f:  # pylint: disable=W1514,unspecified-encoding  # system encoding is fine  # NOQA: E501
            return yaml.safe_load(f)

    @staticmethod
    def constructor_from_name(type_name: str) -> Type[Any]:
        """ Get the named constructor """
        if '.' in type_name:
            module, type_name = type_name.rsplit('.', 1)
            return getattr(sys.modules[module], type_name)
        try:
            return (__builtins__[type_name] if isinstance(__builtins__, dict)
                    else getattr(__builtins__, type_name))
        except (KeyError, AttributeError):
            return globals()[type_name]

    def load(
        self,
        paths: Union[None, str, Iterable[str], Iterable[os.PathLike]] = None
    ) -> None:
        """ Load configuration from the first found file in the list of paths
        """
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
        if not isinstance(data, Mapping):
            raise TypeError(f'Configuration file "{path}" should be a mapping,'
                            f' but is "{type(data).__name__}"')
        # available_options = dataclasses.asdict(self)  # does not work
        available_options = {k.name: k for k in dataclasses.fields(self)}
        for name, raw_value in data.items():
            option = available_options[name]
            vtype_raw = getattr(option, 'type', None)
            if vtype_raw is None or (vtype_raw == 'str' and
                                     isinstance(raw_value, str)):
                setattr(self, name, raw_value)
                continue
            vtype = self.constructor_from_name(vtype_raw) if isinstance(
                vtype_raw, str) else vtype_raw
            setattr(self, name, vtype(raw_value))

    def argparse_args(
            self) -> Generator[Tuple[List[str], ConfigOption], None, None]:
        """ Generate argparse arguments based on the Config class """
        yield (['--help', '-h', '-?'],
               ConfigOption(
                   action=CustomHelpAction,
                   help='Show this help message and exit',
                   nargs=0))
        for conf_field in dataclasses.fields(self):
            option = cast(ConfigOption, conf_field.metadata)
            name = conf_field.name.replace('_', '-')
            parser_kwargs: ConfigOption = option.copy()
            if hasattr(self, conf_field.name):
                # a value is already loaded from the config file;
                # just removing the default is not enough for bool
                parser_kwargs['default'] = getattr(self, conf_field.name)
                parser_kwargs['required'] = False
            elif ('default' not in parser_kwargs and
                  conf_field.default is not dataclasses.MISSING):
                parser_kwargs['default'] = conf_field.default
            short_name = parser_kwargs.pop('short_name', None)
            parser_args = ([f'--{name}'] +
                           ([] if short_name is None else [f'-{short_name}']))
            yield parser_args, parser_kwargs

    def argument_parser(self) -> argparse.ArgumentParser:
        """ Generate an argparse.ArgumentParser instance based on the Config
            class
        """
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
        """ Apply the argparse.Namespace instance to the Config instance """
        for conf_field in dataclasses.fields(self):
            name = conf_field.name.replace('-', '_')
            new_value = getattr(args, name)
            if new_value is not None or not hasattr(self, name):
                setattr(self, name, getattr(args, name))

        if self.debug:
            log_level, env_log_level_error = logging.DEBUG, None
        else:
            log_level, env_log_level_error = get_env_log_level()
        logging.basicConfig(level=log_level, force=logging_force_reconfig)
        if env_log_level_error is not None:
            log.warning('%s', env_log_level_error)

    def process_cli(self) -> argparse.Namespace:
        """ Parse command line arguments and apply them to the Config instance
        """
        args = self.argument_parser().parse_args()
        self.apply_args(args)
        return args


config: Config


class INWXClientWrapper:
    """ An app-specific wrapper for the INWX Domrobot client """
    client: INWX.Domrobot.ApiClient

    def api(self,
            api_method: str,
            method_params: Optional[Dict] = None) -> Dict:
        """ Call an API method """
        client = self.client
        r = client.call_api(api_method, method_params)  # type: ignore
        if config.debug:
            log.debug('INWX %s: %s', api_method, r)
        if r['code'] != 1000:
            raise RuntimeError('INWX login failed', r['msg'])
        return r['resData']

    def login(self) -> None:
        """ Log in to the INWX API """
        try:
            client, logout_was_registered_before = self.client, True
        except AttributeError:
            self.client = client = INWX.Domrobot.ApiClient(
                api_url=INWX.Domrobot.ApiClient.API_LIVE_URL,
                api_type=INWX.Domrobot.ApiType.JSON_RPC,
                client_transaction_id=str(time.time()),
                debug_mode=config.debug)
            logout_was_registered_before = False

        if logout_was_registered_before:
            try:
                client.logout()
            except Exception:  # pylint: disable=broad-exception-caught
                pass

        with open(config.inwx_auth_file_path) as f:
            auth_data = yaml.safe_load(f)

        r = client.login(**auth_data)
        if r['code'] != 1000:
            raise RuntimeError('INWX login failed', r['msg'])

        if config.debug:
            r = client.call_api('account.check')
            log.debug('INWX account.check: %s', r)

        if not logout_was_registered_before:
            atexit.register(client.logout)

    def compare_ns_records(self, domain: str, refs: List[str]) -> bool:
        """ Compare the NS records to the reference """
        res = self.api('nameserver.info', {'domain': domain})
        nses = []
        for rec in res['record']:
            if rec['type'] == 'NS':
                # ns_ids.append(rec['id'])
                nses.append(rec['content'])
        if config.debug and nses != refs:
            log.debug("NS records for %s %s and don't match the reference %s",
                      domain, nses, refs)
        return nses == refs

    def domain_update(self, domain: str, parameters: Dict[str, Any]) -> Dict:
        """ Update the domain """
        return self.api('domain.update', {'domain': domain, **parameters})


inwx_wrapper: INWXClientWrapper


class DomainData(TypedDict):
    TTL: int
    NS: List[str]


def dns_ns_records_match(existing_records: dns.resolver.Answer,
                         reference: List[str]) -> bool:
    """ Compare the NS records """
    existing = [str(record) for record in existing_records]
    reference = [
        record if record.endswith('.') else f'{record}.' for record in reference
    ]
    if existing == reference:
        return True
    log.info(f'NS records are different: {existing} != {reference}')
    return False


def update_ns_records(domain: str, values: List[str]) -> None:
    """ Update the DNS records """
    global inwx_wrapper  # pylint: disable=global-statement
    try:
        w = inwx_wrapper
    except NameError:
        inwx_wrapper = w = INWXClientWrapper()
        w.login()

    if not w.compare_ns_records(domain, values):
        log.debug('NS records are up to date, refreshing the domain')
        return w.domain_update(domain)
    log.warning("NS records for %s don't match the config", domain)


def main() -> None:
    """ Executed when run from the command line """
    # pylint: disable=R0801,duplicate-code  # NOQA: E501
    config.process_cli()

    domains: Dict[str, DomainData]

    with open(config.domains_config_file_path) as f:
        domains = yaml.safe_load(f)

    for domain, data in domains.items():
        values = data['NS']
        try:
            existing_records = dns.resolver.resolve(domain, 'NS')
        except dns.resolver.NXDOMAIN:
            update_ns_records(domain, values)
            break
        if not dns_records_match(existing_records, values):
            update_ns_records(domain, values)
            continue
        log.debug('%s %s records are up to date', domain, 'NS')


if __name__ == '__main__':
    # This is executed when run from the command line
    config = Config()
    main()
