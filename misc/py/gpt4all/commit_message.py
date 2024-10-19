#!/usr/bin/env python3
""" Generate a commit message based on the changes in the working directory
"""
from __future__ import annotations, generator_stop

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
import dataclasses
from enum import StrEnum
import logging
import os
import pathlib
import re
import shlex
import subprocess
import sys
from dataclasses import field as dc_field
from typing import (Any, Callable, Dict, Generator, Iterable, List, Mapping,
                    NoReturn, Optional, Tuple, Type, TypedDict, Union, cast)

# Installable modules https://pypi.org/
import appdirs
import yaml
from gpt4all import GPT4All

# Local modules
#from . import something


class ChatMarkupLanguageLlama(StrEnum):
    """ Chat Markup Language for the Llama model """
    MODEL_NAME = 'Meta-Llama-3.1-8B-Instruct-128k-Q4_0.gguf'
    # SYSTEM_PROMPT = ('<|start_header_id|>system<|end_header_id|>\n'
    #                  'Cutting Knowledge Date: December 2023\n'
    #                  'You are a helpful assistant.<|eot_id|>')
    SYSTEM_PROMPT_START = '<|start_header_id|>system<|end_header_id|>\n'
    SYSTEM_PROMPT_END = '<|eot_id|>\n'
    # PROMPT_TEMPLATE = (
    #     '<|start_header_id|>user<|end_header_id|>'
    #     '%1<|eot_id|><|start_header_id|>assistant<|end_header_id|>'
    #     '%2')
    USER_PROMPT_START = '<|start_header_id|>user<|end_header_id|>'
    USER_PROMPT_END = '<|eot_id|>\n<|start_header_id|>assistant<|end_header_id|>'


# https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/ai-services/openai/includes/chat-markup-language.md
class ChatMarkupLanguageMistral(StrEnum):
    """ Chat Markup Language for the Mistral model """
    MODEL_NAME = 'mistral-7b-openorca.gguf2.Q4_0.gguf'
    SYSTEM_PROMPT_START = '<|im_start|>system\n'
    SYSTEM_PROMPT_END = '\n<|im_end|>\n'
    # <|im_end|> in the user prompt is for the last assistant response
    USER_PROMPT_START = '\n<|im_end|>\n<|im_start|>user\n'
    USER_PROMPT_END = '\n<|im_end|>\n<|im_start|>assistant\n'


Model = ChatMarkupLanguageLlama
MODEL_NAME = Model.MODEL_NAME
SYSTEM_PROMPT = (
    Model.SYSTEM_PROMPT_START +
    "You are a helpful assistant summarizing changes." +
    Model.SYSTEM_PROMPT_END)

PER_FILE_PROMPT_TEMPLATE = (
    'Write a terse technical 1-10 word summary describing the subset of '
    'changes in file "{filename}" useful for creating commit messages.\n'
    'Do not include the filename or amount of changes in the summary.\n'
    'Below, "+" as first character of a line means the line is added to the '
    'file "{filename}", "-" means the line is removed.\n'
    '\n{diff}')

FINAL_PROMPT_TEMPLATE = (
    'change_type is one of:\n'
    '- feat: A new feature\n'
    '- fix: A bug fix\n'
    '- docs: Documentation only changes\n'
    '- style: Changes that do not affect the meaning of the code\n'
    '- refactor: A code change that neither fixes a bug nor adds a feature\n'
    '- perf: A code change that improves performance\n'
    '- test: Adding missing tests or correcting existing tests\n'
    '- build: Changes that affect the build system or external dependencies\n'
    '- ci: Changes to our CI configuration files and scripts\n'
    '- chore: Other changes that don\'t modify src or test files\n'
    '\n'
    'Change summaries:\n'
    '{change_summaries}\n'
    'Produce the commit message using format:\n'
    '```\n'
    'change_type (scope): short description\n'
    '\n'
    'Longer description\n'
    '\n'
    '```\n'
    'without any additional text.\n')

# >git diff --cached  .dockerignore
# diff --git a/.dockerignore b/.dockerignore
# index 178c111..d48c8c3 100644
# --- a/.dockerignore
# +++ b/.dockerignore
# @@ -1,3 +1,5 @@
#  .dockerignore
#  Dockerfile
#  build_logs/
# +local_dev_scripts/
# +README.md

GIT_DIFF_LINES_TO_SKIP_FILE = (
    'chown ',
    'Binary files ',
    'deleted file mode ',
)
GIT_DIFF_SKIPLINES = (
    'diff --git ',
    'index ',
    'new file mode ',
    '--- ',
    '+++ ',
    '@@ ',
)

log = logging.getLogger(
    os.path.basename(__file__) if __name__ == '__main__' else __name__)


def get_env_log_level(
    default: int = logging.DEBUG if __debug__ else logging.INFO
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
    """ Script parameters class, all parameters can be loaded from a YAML file,
        and overridden from the command line.
    """
    # pylint: disable=R0801,duplicate-code,R0902,too-many-instance-attributes  # NOQA: E501
    commit_message_path: pathlib.Path = dc_field(
        metadata=ConfigOption(
            help='Path to the file with the commit message', short_name='p'))
    system_prompt: str = dc_field(
        metadata=ConfigOption(
            default=SYSTEM_PROMPT, help='System prompt to be sent only once'))
    per_file_prompt_template: str = dc_field(
        metadata=ConfigOption(
            default=PER_FILE_PROMPT_TEMPLATE,
            help='Prompt template for each file. You can use {{diff}}, '
            '{{status_line}} and {{filename}} placeholders.'))
    final_prompt_template: str = dc_field(
        metadata=ConfigOption(
            default=FINAL_PROMPT_TEMPLATE,
            help='Final prompt template. You can use {{change_summaries}} and '
            '{{git_status}} placeholders.'))
    prompt_prefix: str = dc_field(
        metadata=ConfigOption(
            default=Model.USER_PROMPT_START, help='Prefix for each LLM prompt'))
    prompt_suffix: str = dc_field(
        metadata=ConfigOption(
            default=Model.USER_PROMPT_END, help='Suffix for each LLM prompt'))
    prompt_max_len: int = dc_field(
        metadata=ConfigOption(
            default=2048,
            help='Maximum length of the prompt to send to the model'))
    model: str = dc_field(
        metadata=ConfigOption(
            # default='Nous-Hermes-2-Mistral-7B-DPO.Q4_0.gguf',
            default=MODEL_NAME,
            help='Model to use'))
    device: str = dc_field(
        metadata=ConfigOption(
            default='gpu',
            help='Device to use for chatbot, e.g. gpu, amd, nvidia, intel. Defaults to GPU.'
        ))
    debug: str = dc_field(
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


def split_prompt(prompt: str, max_len: int) -> Generator[str, None, None]:
    """ Split the prompt to fragments under max_len length, breaking on lines
        or words if there are lines longer than max_len.
    """
    current_fragment = ''
    for line in prompt.splitlines():
        if current_fragment and len(current_fragment) + len(line) >= max_len:
            yield current_fragment
            current_fragment = ''
        current_fragment += line + '\n'
        while len(current_fragment) >= max_len:
            # The current line is too long
            last_space = current_fragment.rfind(' ', 0, max_len)
            if last_space == -1:
                yield current_fragment[:max_len]
                current_fragment = current_fragment[max_len:]
                continue
            yield current_fragment[:last_space]
            current_fragment = current_fragment[last_space + 1:]

    if current_fragment:
        yield current_fragment


def streaming_generate(chat: GPT4All, prompt: str, **kwargs) -> str:
    """ Generate text from the GPT-4-All model, printing it as it is generated
    """
    # <|im_start|>system
    # Provide some context and/or instructions to the model.
    # <|im_end|>
    # <|im_start|>user
    # The user’s message goes here
    # <|im_end|>
    # <|im_start|>assistant

    prompt_break = '...\n'
    prompt_max_cut_len = config.prompt_max_len - len(prompt_break)  # pylint: disable=E0601,used-before-assignment  # NOQA: E501
    if len(prompt) > config.prompt_max_len:
        return '\n'.join(
            streaming_generate(chat, prompt_fragment + prompt_break, **kwargs)
            for prompt_fragment in split_prompt(prompt, prompt_max_cut_len))

    log.debug('Prompt: %s\nResponse:', prompt)
    out = ''
    for token in chat.generate(prompt, **kwargs, streaming=True):
        print(token, end='', flush=True, file=sys.stderr)
        out += token
    print(file=sys.stderr)
    return out


def unescape_c_string_numeral(fragment: str) -> Tuple[str, int]:
    """ Unescape a C-style string escape sequence
            
        Returns the unescaped character and the offset to the next character
    """
    start_char = fragment[0]
    if start_char >= '0' and start_char <= '8':  # octal escape
        number_length = re.match(r'[0-8]+', fragment).end()
        return chr(int(fragment[0:number_length], 8)), number_length
    hex_sequence_length = {
        'x': 2,
        'u': 4,
        'U': 8,
    }
    hex_number_end = hex_sequence_length.get(start_char) + 1
    return chr(int(fragment[1:hex_number_end], 16)), hex_number_end


def fill_c_string_escape_seq(
) -> Dict[str, Union[str, Callable[[str], Tuple[str, int]]]]:
    """ Fill the dictionary with C-style string escape sequences
        https://en.wikipedia.org/wiki/Escape_sequences_in_C
    """
    escape_dict = {
        'a': '\a',
        'b': '\b',
        'e': '\x1b',
        'f': '\f',
        'n': '\n',
        'r': '\r',
        't': '\t',
        'v': '\v',
        'x': unescape_c_string_numeral,  # hex escape
        'u': unescape_c_string_numeral,  # unicode escape
        'U': unescape_c_string_numeral,  # unicode escape
    }
    for i in range(9):
        escape_dict[str(i)] = unescape_c_string_numeral
    # all other characters are left as is
    return escape_dict


c_string_escape_seq = fill_c_string_escape_seq()


def parse_next_filename(line: str) -> Tuple[str, int]:
    """ Parse the next filename from the git status line

        XY PATH
        XY ORIG_PATH -> PATH
        
        Where PATH and ORIG_PATH are either plain names,
        or a C-style quoted strings if they contain spaces.

        Returns the filename and the offset to the part of the line after
        the filename.
    """
    # Unquoted filenames are separated by spaces
    if line[0] != '"':
        end_space = line.find(' ', 1)
        if end_space == -1:
            return line, -1
        return line[:end_space], end_space

    # Quoted filenames need to be parsed
    out_name = ''
    parse_start = 1  # Skip the opening quote
    while True:
        next_backslash = line.find('\\', parse_start)
        next_quote = line.find('"', parse_start)
        if next_backslash == -1 or next_quote < next_backslash:
            if next_quote == -1:
                raise ValueError('Filename quote not closed')
            out_name += line[parse_start:next_quote]
            return out_name, next_quote + 1
        after_backslash = line[next_backslash + 1]
        out_name += line[parse_start:next_backslash] + c_string_escape_seq.get(
            after_backslash, after_backslash)
        parse_start = next_backslash + 2


def parse_filenames(line: str) -> Tuple[str, Optional[str]]:
    """ Parse the filenames from the git status line

        XY PATH
        XY ORIG_PATH -> PATH
        
        Where PATH and ORIG_PATH are either plain names,
        or a C-style quoted strings if they contain spaces.
    """
    first_name, offset = parse_next_filename(line[3:])
    if offset == -1:
        return first_name, None
    second_name, _ = parse_next_filename(line[3 + offset:])
    return first_name, second_name


def main() -> None:
    """ Executed when run from the command line """
    # pylint: disable=R0801,duplicate-code  # NOQA: E501
    config.process_cli()  # pylint: disable=E0601,used-before-assignment

    gpt4all_instance = GPT4All(model_name=config.model, device=config.device)

    if config.commit_message_path is not None:
        try:
            with open(config.commit_message_path) as f:  # pylint: disable=W1514,unspecified-encoding  # NOQA: E501
                commit_message = f.read()
            log.debug('Orignial commit message: %s', commit_message)
        except FileNotFoundError:
            pass
    git_status = subprocess.getoutput('git status --porcelain')
    summaries: list[str] = []
    with gpt4all_instance.chat_session(
            config.system_prompt,
            config.prompt_prefix + '{0}' + config.prompt_suffix) as chat:
        # Summarize diffs for each file
        for status_line in git_status.splitlines():
            log.debug('Git status: %s', status_line)
            cache_status = status_line[0]
            if cache_status == ' ' or cache_status == '?':
                continue
            filename = parse_next_filename(status_line[3:])[0]
            # filename, new_filename = parse_filenames(line)
            if cache_status == 'M':
                args = [
                    'git', 'diff', '--minimal', '--histogram', '--color=never',
                    '--cached', '--unified=0', '--', filename
                ]
                log.debug('Running:\n%s', shlex.join(args))
                diff = subprocess.run(
                    args, capture_output=True, text=True, check=True).stdout
                log.debug('File %s diff:\n%s', filename, diff)
                # Skip the first 5 lines of the diff
                diff_lines = diff.splitlines()
                for i, line in enumerate(diff_lines):
                    if line.startswith(GIT_DIFF_LINES_TO_SKIP_FILE):
                        diff_lines = None
                        break
                    if line.startswith(GIT_DIFF_SKIPLINES):
                        diff_lines[i] = None
                        continue
                if diff_lines is None:
                    continue
                diff = '\n'.join([line for line in diff.splitlines() if line])
                query = config.per_file_prompt_template.format(
                    diff=diff, status_line=status_line, filename=filename)
                summaries.append(filename + ': ' +
                                 streaming_generate(chat, query))
            else:
                summaries.append(status_line)
        # Generate the commit message
        prompt = config.final_prompt_template.format(
            git_status=git_status, change_summaries='\n'.join(summaries))
        commit_message = streaming_generate(gpt4all_instance, prompt)
        if config.commit_message_path:
            with open(config.commit_message_path, 'w') as f:  # pylint: disable=W1514,unspecified-encoding  # NOQA: E501
                f.write(commit_message)


if __name__ == '__main__':
    # This is executed when run from the command line
    config = Config()
    main()
