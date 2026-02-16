#!/usr/bin/env python3
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import dataclasses
from fnmatch import fnmatch
import importlib
import logging
import os
import sys
import tempfile
import threading
from collections import deque
from dataclasses import field as dc_field
from datetime import datetime
from pathlib import Path
from typing import (
    Any,
    Deque,
    Dict,
    Generator,
    Iterable,
    List,
    Literal,
    Mapping,
    NoReturn,
    NotRequired,
    Optional,
    Tuple,
    Type,
    TypedDict,
    Union,
    cast,
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
    ('platformdirs'),
    ('httpx', 'httpx[http2]'),
    ('yaml', 'pyyaml'),
    ('werkzeug'),
    ('lxml.html', 'lxml'),
])
# Actual imports happen above; these ones are for type checking
# Installable modules https://pypi.org/
import httpx  # NOQA: E402
import lxml.html  # NOQA: E402
import platformdirs  # NOQA: E402
import werkzeug  # NOQA: E402
import yaml  # NOQA: E402

# Werkzeug submodules must be imported explicitly
import werkzeug.http  # NOQA: E402
import werkzeug.utils  # NOQA: E402

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(
        default: int = logging.INFO) -> Tuple[int, Optional[str]]:
    """ Get the log level from the environment variable LOG_LEVEL """
    # pylint: disable=R0801,duplicate-code
    env_debug = os.getenv('DEBUG', '')
    if env_debug > '0' and env_debug[:1] != 'n':
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
    yield os.path.join(platformdirs.user_config_dir(), basename, 'config.yml')
    yield (os.path.join(platformdirs.site_config_dir(), basename, 'config.yml')
           if sys.platform in {'win32', 'darwin'} else os.path.join(
               '/etc', basename + '.config.yml'))


def guess_dist_base(out_dir: Path) -> Path:
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
    # If no suitable parent directory found, return the output directory
    return out_dir


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


class ConfigOption(TypedDict):
    # Attributes specific for Config.argparse_args()
    positional: NotRequired[bool]
    short_name: NotRequired[str]
    # Standard argparse attributes
    # https://docs.python.org/3/library/argparse.html#the-add-argument-method
    action: NotRequired[Union[str, Type[argparse.Action]]]
    nargs: NotRequired[Union[int, Literal['?', '*', '+'], None]]
    const: NotRequired[Any]
    default: NotRequired[Any]
    type: NotRequired[Type]
    choices: NotRequired[Iterable[Any]]
    required: NotRequired[bool]
    help: NotRequired[str]
    metavar: NotRequired[str]
    dest: NotRequired[str]
    deprecated: NotRequired[bool]


@dataclasses.dataclass(slots=True)
class Config:
    """ Script parameters class, all parameters can be loaded from a YAML file,
        and overridden from the command line.
    """
    # pylint: disable=R0801,duplicate-code,R0902,too-many-instance-attributes  # NOQA: E501
    url: httpx.URL = dc_field(metadata=ConfigOption(
        type=httpx.URL,
        help='URL to download the distributive from (webpage or direct)',
        positional=True))
    dist_mask: Optional[str] = dc_field(metadata=ConfigOption(
        nargs='?',
        positional=True,
        help='Mask for the distributive file name, e.g. "dist-*.tar.gz". '
        'If not specified, the URL must point to a file, not a webpage.'))
    rename: Optional[str] = dc_field(metadata=ConfigOption(
        help='Rename the distributive, e.g. "dist.tar.gz".'))
    out_dir: Path = dc_field(metadata=ConfigOption(
        type=Path,
        help='Directory to save the downloaded distributive to. '
        'If not specified, srcpath environment variable is used.'))
    root_dir: Path = dc_field(metadata=ConfigOption(
        type=Path,
        help='Root directory to keep the relative path of the files matching '
        'the {dist_mask} in the {out_dir}. If not specified, env var '
        'baseDistributives is used if defined, and otherwise the dir is found '
        'using a wierd heuristic (see source).'))
    cleanup_action: Optional[str] = dc_field(metadata=ConfigOption(
        choices=['echo', 'move', 'delete'],
        help='Optional action to perform on the files matching the {dist_mask} '
        'in the {out_dir}:\n'
        '* "move" moves them to the {archive_dir}, with relative '
        'path after the {root_dir},\n'
        '* "delete" deletes them,\n'
        '* "echo" just prints the paths.'))
    archive_dir: Path = dc_field(metadata=ConfigOption(
        type=Path,
        help='Destination for moving the files with `cleanup_action=move`. '
        r'Default is "{root_dir}\_old".'))

    debug: bool = dc_field(metadata=ConfigOption(
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
            vtype = None
            metadata = getattr(option, 'metadata', None)
            if metadata is not None:
                vtype = metadata.get('type', None)
            if vtype is None:
                vtype_raw = getattr(option, 'type', None)
                if vtype_raw is None or (vtype_raw == 'str'
                                         and isinstance(raw_value, str)):
                    setattr(self, name, raw_value)
                    continue
                vtype = self.constructor_from_name(vtype_raw) if isinstance(
                    vtype_raw, str) else vtype_raw
            setattr(self, name, vtype(raw_value))

    def argparse_args(
            self) -> Generator[Tuple[List[str], ConfigOption], None, None]:
        """ Generate argparse arguments based on the Config class """
        for conf_field in dataclasses.fields(self):
            option = cast(ConfigOption, conf_field.metadata)
            parser_kwargs: ConfigOption = option.copy()

            positional = parser_kwargs.pop('positional', False)
            parser_args = ([conf_field.name] if positional else
                           ['--' + conf_field.name.replace('_', '-')])
            if short_name := parser_kwargs.pop('short_name', None):
                parser_args.append('-' + short_name)

            if hasattr(self, conf_field.name):
                # a value is already loaded from the config file;
                # just removing the default is not enough for bool
                parser_kwargs['default'] = getattr(self, conf_field.name)
                if not positional:
                    parser_kwargs['required'] = False
            elif (conf_field.default is not dataclasses.MISSING
                  and 'default' not in parser_kwargs):
                # no value loaded from config file, use the dataclass default
                parser_kwargs['default'] = conf_field.default
            yield parser_args, parser_kwargs
        yield (['--help', '-h', '-?'],
               ConfigOption(action=CustomHelpAction,
                            help='Show this help message and exit',
                            nargs=0))

    def argument_parser(self) -> argparse.ArgumentParser:
        """ Generate an argparse.ArgumentParser instance and populate it
            with arguments based on the Config class
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
        if not config.out_dir:
            config.out_dir = Path(os.getenv('srcpath', ''))
        if not config.root_dir:
            base_distributives = os.getenv('baseDistributives')
            config.root_dir = (guess_dist_base(config.out_dir)
                               if base_distributives is None else
                               Path(base_distributives))
        if not config.archive_dir:
            config.archive_dir = config.root_dir / '_old'
        return args


config: Config


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


def parse_html_links(base_url: httpx.URL,
                     data: bytes,
                     name_mask: Optional[str] = None) -> List[httpx.URL]:
    """ Parse links from the given HTML """
    out: List[httpx.URL] = []
    dlpage = lxml.html.fromstring(data)  # , str(base_url))
    # Find all links in the HTML page
    for link in dlpage.xpath('//a[@href]'):
        href = link.get('href')
        if not href:
            continue
        full_href = base_url.join(href)
        base_name = os.path.basename(full_href.path)
        if (name_mask is not None and not fnmatch(base_name, name_mask)):
            continue
        out.append(full_href)
    return out


def download(cl: httpx.Client, url: httpx.URL) -> List[Path]:
    out: List[Path] = []
    with cl.stream('GET', url) as r:
        r.raise_for_status()
        log.debug('%s', r.headers)
        content_disp = r.headers.get('content-disposition')
        local_filename = (config.out_dir / werkzeug.utils.secure_filename(
            werkzeug.http.parse_options_header(content_disp)[1]['filename'] if
            content_disp is not None else os.path.basename(config.url.path)))
        if config.dist_mask:
            # If ther is a mask and the URL downloads a webpage,
            # needs to be parsed to find the file
            content_type: Optional[str] = r.headers.get('content-type')
            if content_type is not None and content_type.startswith('text/'):
                for link in parse_html_links(r.url, r.read()):
                    out.extend(download(cl, link))
            elif not local_filename.match(config.dist_mask):
                log.warning('Downloaded file %s does not match the mask %s',
                            local_filename, config.dist_mask)
                return out
        if config.rename:
            local_filename = local_filename.with_name(config.rename)
        last_modified = werkzeug.http.parse_date(
            r.headers.get('last-modified'))
        if last_modified:
            log.info('Remote file "%s" modified %s', local_filename,
                     last_modified)
            last_modified_ts = last_modified.timestamp()
            if os.path.exists(local_filename):
                current_time = os.path.getmtime(local_filename)
                if current_time == last_modified_ts:
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


def cleanup(do_not_delete_files: Iterable[Path]) -> None:
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
    keep_files = set(
        str(v.relative_to(config.out_dir)) for v in do_not_delete_files)
    list_path = (config.out_dir /
                 os.path.basename(__file__)).with_suffix('.list')

    if config.dist_mask:
        cleanup_list = set(
            str(p) for p in config.out_dir.glob(config.dist_mask)
            if p.is_file())
    else:
        try:
            cleanup_list = set(list_path.read_text().strip().splitlines())
        except FileNotFoundError:
            cleanup_list = set()

    # Remove the files that should not be deleted
    cleanup_list -= keep_files
    if not config.dist_mask:
        # If the dist_mask is not set, update the list file
        # with the files that should not be deleted now
        # (they will be removed on the next call)
        list_path.write_text('\n'.join(cleanup_list | keep_files) + '\n')

    match config.cleanup_action:
        case 'echo':
            for i in cleanup_list:
                print(i)
        case 'move':
            archive_dir = config.archive_dir / config.out_dir.relative_to(
                config.root_dir)
            for i in cleanup_list:
                src = config.out_dir / i
                if src.is_file():
                    dest = archive_dir / i
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    log.info('Moving %s to %s', src, dest)
                    os.replace(src, dest)
        case 'delete':
            for i in cleanup_list:
                src = config.out_dir / i
                if src.is_file():
                    log.info('Deleting %s', src)
                    os.remove(src)


def main() -> None:
    """ Executed when run from the command line """
    # pylint: disable=R0801,duplicate-code  # NOQA: E501
    config.process_cli()

    with httpx.Client(http2=True) as cl:
        local_filenames = download(cl, config.url)
    if not local_filenames:
        return
    print(*local_filenames, sep='\n', end='')

    if config.cleanup_action:
        cleanup(local_filenames)


if __name__ == '__main__':
    # This is executed when run from the command line
    config = Config()
    main()
