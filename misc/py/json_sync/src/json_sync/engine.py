from __future__ import annotations
import json
import logging
import re
from pathlib import Path
from pprint import pformat
from typing import Dict, List, Optional, TypeVar, TypedDict, Union

DictFilter = Dict[str, Union['DictFilter', bool]]

log = logging.getLogger(__name__)

PFORMAT_ARGS = {
    'depth': 1,
    'compact': True,
    'sort_dicts': False,
    'width': 32768
}


def filter_dict(data: Dict, dict_filter: DictFilter) -> Dict:
    """ Filter a dictionary based on a filter specification """
    if log.isEnabledFor(logging.DEBUG):
        log.debug('Applying filter %s to %s', dict_filter,
                  pformat(data, **PFORMAT_ARGS))
    result = {}
    for key in set(data) & set(dict_filter):
        filter_value = dict_filter[key]
        value = data[key]
        if isinstance(filter_value, dict) and isinstance(value, dict):
            result[key] = filter_dict(value, filter_value)
        elif filter_value is True:
            result[key] = value
    return result


def load_json(path: Path) -> Dict:
    """ Load JSON data from a file """
    log.debug('Loading JSON file %s', path)
    with path.open('rb') as f:
        return json.load(f)


TD = TypeVar('TD', bound=Dict)


class DeletedKey:
    pass


deleted_key = DeletedKey()


def dict_diff(old: TD, new: TD) -> TD:
    """ Compute the difference between two dictionaries """
    changes: TD = {}
    old_keys = set(old)
    new_keys = set(new)
    for key in old_keys & new_keys:
        old_value = old[key]
        new_value = new[key]
        if old_value == new_value:
            continue
        if log.isEnabledFor(logging.DEBUG):
            log.debug('Value "%s" changed from "%s" to "%s"', key,
                      pformat(old_value, **PFORMAT_ARGS),
                      pformat(new_value, **PFORMAT_ARGS))
        if isinstance(old_value, dict) and isinstance(new_value, dict):
            if sub_changes := dict_diff(old_value, new_value):
                changes[key] = sub_changes
        else:
            changes[key] = new_value
    for key in new_keys - old_keys:
        if log.isEnabledFor(logging.DEBUG):
            log.debug('Key "%s" is added (value "%s")', key,
                      pformat(new[key], **PFORMAT_ARGS))
        changes[key] = new[key]
    for key in old_keys - new_keys:
        if log.isEnabledFor(logging.DEBUG):
            log.debug('Key "%s" is removed in (old value "%s")', key,
                      pformat(old[key], **PFORMAT_ARGS))
        changes[key] = deleted_key
    if log.isEnabledFor(logging.DEBUG):
        log.debug('Computed dict diff from %s to %s: %s',
                  pformat(old, **PFORMAT_ARGS), pformat(new, **PFORMAT_ARGS),
                  pformat(changes, **PFORMAT_ARGS))
    return changes


class ConflictingValue:
    pass


conflicting_value = ConflictingValue()


def merge_dicts(base: Dict, another: Dict, key_prefix: str = '') -> bool:
    """ Update base to include changes from another,
        mark conflicts with conflicting_value.
        Return True if any changes were made.
    """
    changes = False
    base_keys = set(base)
    another_keys = set(another)

    # resolve common keys
    for key in base_keys & another_keys:
        base_value = base[key]
        another_value = another[key]
        if isinstance(base_value, dict) and isinstance(another_value, dict):
            if merge_dicts(base_value, another_value, key_prefix + key + '.'):
                changes = True
        elif base_value != another_value:
            # Mark conflicting key
            log.warning('Conflict on key %s%s: %s vs %s', key_prefix, key,
                        base_value, another_value)
            base[key] = conflicting_value
            changes = True

    # Update unique keys
    if another_keys - base_keys:
        base.update({key: another[key] for key in another_keys - base_keys})
        changes = True

    return changes


def recursive_apply(data: Dict, changes: Dict) -> bool:
    modified = False
    for key, value in changes.items():
        if value is deleted_key:
            if key in data:
                del data[key]
                modified = True
        elif value is conflicting_value:
            log.warning('Skipping conflicting change for "%s"', key)
        elif isinstance(value, dict):
            if key not in data or not isinstance(data[key], dict):
                data[key] = {}
                modified = True
            if recursive_apply(data[key], value):
                modified = True
        else:
            if data.get(key, deleted_key) != value:
                data[key] = value
                modified = True
    return modified


class FileOpenParameters(TypedDict):
    encoding: str
    newline: str


class JSONDumpParameters(TypedDict):
    ensure_ascii: bool
    indent: Union[int, str, None]


class FileFormatAndData:
    """ Detect the format parameters based on the file contents """
    path: Path
    raw: bytes
    encoding: str
    newline: str
    eof_newline: bool
    indent: str | int | None
    ensure_ascii: bool
    _log: logging.Logger
    _json: Optional[Dict]

    __slots__ = tuple(__annotations__)

    def __init__(self, path: Path) -> None:
        self._json = None
        self._log = _log = log.getChild(f'FileFormatAndData:{path}')
        self.path = path
        _log.debug('Opening file')
        # Detect encoding and line endings
        with path.open('rb') as f:
            sig = f.read(3)
            if sig == b'\xef\xbb\xbf':
                self.encoding = 'utf-8-sig'
                _log.debug('Detected UTF-8 BOM')
            else:
                f.seek(0)
                self.encoding = 'utf-8'
            _log.debug('Reading the remaining file now')
            self.raw = raw = f.read()
            assert len(raw) > 0, 'File is empty'

        # Detect ensure_ascii
        self.ensure_ascii = re.search(br'\\u[0-9a-fA-F]{4}', raw) is not None
        log.debug('ensure_ascii is %s', self.ensure_ascii)

        # Detect EOF newline
        self.eof_newline = raw[-1:] == b'\n'
        if _log.isEnabledFor(logging.DEBUG):
            _log.debug('Last byte is "%r", %susing EOF newline.', raw[-1:],
                       '' if self.eof_newline else 'not ')
        # Detect indentation
        for i, raw_line in enumerate(raw.splitlines(keepends=True)):
            if i == 0:
                self.newline = '\r\n' if raw_line[-2:] == b'\r\n' else '\n'
                _log.debug('Using newline %r', self.newline)
            elif raw_line.strip():
                indent_match = re.match(b'([ \t]+)', raw_line)
                if indent_match is not None:
                    self.indent = ((len(indent_match.group(1)) or None)
                                   if re.fullmatch(b' +', indent_match.group(1))
                                   else indent_match.group(1).decode('utf-8'))
                    log.debug('Detected indent %r on line %d', self.indent,
                              i + 1)
                    break
        else:
            self.indent = None
            log.debug('No indentation detected')

    def json(self) -> Dict:
        """ Get the JSON data, loading it if necessary """
        if (data := self._json) is not None:
            return data
        self._log.debug('Parsing JSON data')
        self._json = data = json.loads(self.raw)
        return data

    def file_open_parameters(self) -> FileOpenParameters:
        r = {'encoding': self.encoding, 'newline': self.newline}
        self._log.debug('File open parameters: %s', r)
        return r

    def json_dump_parameters(self) -> JSONDumpParameters:
        params = {'ensure_ascii': self.ensure_ascii}
        if self.indent is not None:
            params['indent'] = self.indent
        self._log.debug('JSON dump parameters: %s', params)
        return params


def transactional_json_dump(item: FileFormatAndData, data: Dict) -> None:
    """ Write JSON data to a file transactionally """
    try:
        item.path.with_suffix('.bak').hardlink_to(item.path)
    except OSError:
        log.warning(
            'Hardlink backup failed for %s; copying instead',
            item.path,
            exc_info=True)
        item.path.copy(item.path.with_suffix('.bak'))
    tmp = item.path.with_suffix('.tmp')
    log.debug('Writing JSON file %s via a tmp %s', item.path, tmp)
    with tmp.open('w', **item.file_open_parameters()) as f:
        json.dump(data, f, **item.json_dump_parameters())
        if item.eof_newline:
            f.write('\n')
    tmp.replace(item.path)


def build_prev_versions_paths(json_files: List[FileFormatAndData],
                              prev_version_dir: Path,
                              prev_version_suffix: str) -> List[Path]:
    if not prev_version_dir.is_absolute() or len(
            set([item.path.name for item in json_files])) == len(json_files):
        return [
            item.path.parent / prev_version_dir /
            (item.path.name + prev_version_suffix) for item in json_files
        ]

    # Ensure unique dir/name combinations for previous versions
    # Build unique subdirs based on parent dirs
    # First, take the item names
    prev_subdirs = [item.path.name for item in json_files]
    # Then add parent dirs until all are unique
    for parent_idx in range(min(len(item.path.parents) for item in json_files)):
        prev_subdirs = [
            json_files[i].path.parents[parent_idx].name + '/' + subdir
            for i, subdir in enumerate(prev_subdirs)
        ]
        # Check uniqueness
        if len(set(prev_subdirs)) == len(json_files):
            break
    else:
        raise RuntimeError(
            'Could not determine unique previous version paths for '
            'json_files')
    return [
        p.with_name(p.name + prev_version_suffix) for p in [
            prev_version_dir.joinpath(*subdir.split('/'))
            for subdir in prev_subdirs
        ]
    ]


def sync_json_changes(json_files: List[Union[FileFormatAndData, Path, str]],
                      filter_spec: Union[DictFilter, Path, str, None] = None,
                      prev_version_dir: Optional[Path] = None,
                      prev_version_suffix: str = '') -> None:
    """ Sync changes to multiple JSON files.
        Changes are computed based on the differences from previous versions,
        which are stored either in a separate directory or with a suffix.
        
        If a filter_spec is provided, only the filtered parts of the JSON
        files are considered for computing differences.
    """
    assert len(json_files) >= 2, 'At least 2 JSON files required to sync'
    assert prev_version_dir or prev_version_suffix, (
        'Either prev_version_dir or prev_version_suffix must be specified')
    if any(not isinstance(item, FileFormatAndData) for item in json_files):
        json_files = [
            item
            if isinstance(item, FileFormatAndData) else FileFormatAndData(item)
            for item in json_files
        ]
    json_files: List[FileFormatAndData] = json_files
    prev_version_paths = ([
        item.path.with_name(item.path.name + prev_version_suffix)
        for item in json_files
    ] if prev_version_dir is None else build_prev_versions_paths(
        json_files, prev_version_dir, prev_version_suffix))

    if filter_spec is not None and not isinstance(filter_spec, Dict):
        log.debug('Loading filter spec from %s', filter_spec)
        filter_spec = load_json(filter_spec)

    diffs: Dict[int, Dict] = {}
    for i, files in enumerate(zip(json_files, prev_version_paths)):
        src, prev_path = files
        if not prev_path.exists():
            log.warning(
                'Previous version file %s does not exist; '
                'skipping diff', prev_path)
            # Path.copy() is available in Python 3.14+, released
            prev_path.parent.mkdir(parents=True, exist_ok=True)
            src.path.copy(prev_path)
            continue
        diff = (
            dict_diff(load_json(prev_path), src.json())
            if filter_spec is None else dict_diff(
                filter_dict(load_json(prev_path), filter_spec),
                filter_dict(src.json(), filter_spec)))
        if diff:
            diffs[i] = diff

    if not diffs:
        log.info('No differences found')
        return

    if len(diffs) > 1:
        diff_list = list(diffs.values())
        log.info('Multiple differences found; merging changes')
        # All diffs are merged, so we can just pick one and apply it to all files
        master_diff = diff_list[0]
        for other_diff in diff_list[1:]:
            merge_dicts(master_diff, other_diff)
    else:
        master_diff = next(iter(diffs.values()))

    if log.isEnabledFor(logging.DEBUG):
        log.debug('Master diff to apply: %s',
                  pformat(master_diff, **PFORMAT_ARGS))
    files_to_update_prev = set(diffs)

    for i, src in enumerate(json_files):
        # Optimization: If this item is the only source of changes,
        # it already has the data. Don't rewrite it.
        if len(diffs) == 1 and src in diffs:
            continue

        item_data = src.json()
        if recursive_apply(item_data, master_diff):
            transactional_json_dump(src, item_data)
            files_to_update_prev.add(i)

    for i in files_to_update_prev:
        current_file = json_files[i].path
        prev_path = prev_version_paths[i]
        log.debug('Updating previous version "%s" file for "%s"', prev_path,
                  current_file)
        prev_path.parent.mkdir(parents=True, exist_ok=True)
        current_file.copy(prev_path)

    log.debug('Synchronization complete')
