#!/usr/bin/env python3
r""" If you mess you your system with msconfig "Diagnostic startup" and want
to restore your services Start mode, boot into recovery command line and run
these commands:

```
reg load HKLM\FixSOFTWARE C:\Windows\System32\config\SOFTWARE
reg export "HKLM\FixSOFTWARE\Microsoft\Shared Tools\MSConfig\services" path_on_a_flash_drive\services_backup.reg
reg unload HKLM\FixSOFTWARE
```

Then transfer the reg file to a working system and run this script to convert
the exported `services_backup.reg` file into a `services_Startup.reg` file,
that can be imported into the SYSTEM hive to restore
the services Start mode settings.

Transfer the resulting `services_Startup.reg` file back to the recovery
environment and run these commands to import it into the SYSTEM hive:
```
reg load HKLM\FixSYSTEM C:\Windows\System32\config\SYSTEM
reg import path_on_a_flash_drive\services_Startup.reg
reg unload HKLM\FixSYSTEM
```
"""
from __future__ import annotations

# Python Standard Library modules https://docs.python.org/3/py-modindex.html
import argparse
from io import TextIOBase
import logging
import re
import sys
from pathlib import Path

log = logging.getLogger(Path(__file__).stem)


def reg_read(infile: TextIOBase) -> dict[str, dict[str, str]]:
    """ Read a .reg file and return its contents as a nested dictionary """
    reg_data: dict[str, dict[str, str]] = {}
    line_continuation = False
    name = value = None
    current_values: dict[str, str] = {}
    for rawline in infile:
        line = rawline.strip()
        if not line or line.startswith(';'):
            continue
        if name is None and line == 'Windows Registry Editor Version 5.00':
            continue
        if line_continuation:
            # Continue previous line
            value += '\n' + line
            line_continuation = line.endswith('\\')
            if not line_continuation:
                current_values[name] = value
            continue
        if line.startswith('[') and line.endswith(']'):
            current_values = {}
            reg_data[line[1:-1].strip()] = current_values
            continue
        if '=' in line:
            name, data = map(str.strip, line.split('=', 1))
            line_continuation = data.endswith('\\')
            if not line_continuation:
                current_values[name.strip('"')] = data
        else:
            log.warning('Unrecognized line in .reg file: %s', line)
    return reg_data


def main() -> None:
    """ Executed when run from the command line """
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument(
        'infile',
        type=Path,
        help='Path to the exported .reg file with msconfig backup to parse')
    ap.add_argument(
        'outfile',
        type=Path,
        help='Path to the output services_Startup.reg file to create')
    ap.add_argument(
        '--target-hive-root',
        '-t',
        default=r'HKEY_LOCAL_MACHINE\FixSYSTEM',
        help='Root of the loaded hive for the services_Startup.reg file.')
    args = ap.parse_args()
    logging.basicConfig(level=logging.DEBUG)
    infile_path: Path = args.infile
    with (sys.stdin if infile_path == Path('-') else infile_path.open(
            'r', encoding='utf-16')) as infile:
        rawdata = reg_read(infile)
    # Service name -> Start value
    data: dict[str, int] = {}
    for k, v in rawdata.items():
        if m := re.fullmatch(
                r'.*Microsoft\\Shared Tools\\MSConfig\\services\\(.+)', k):
            service_name_from_key = m.group(1)
            for vn, vv in v.items():
                # "Start" value is in the key named after the service
                # [HKEY_LOCAL_MACHINE\TempSoft\Microsoft\Shared Tools\MSConfig\services\ADPSvc]
                # "ADPSvc"=dword:00000003
                # "YEAR"=dword:000007ea
                # "MONTH"=dword:00000001
                # "DAY"=dword:00000010
                # "HOUR"=dword:00000009
                # "MINUTE"=dword:00000020
                # "SECOND"=dword:0000002f
                if vn == service_name_from_key:
                    data[vn] = vv
                    break
            else:
                log.warning('No Start value found for service %s',
                            service_name_from_key)
    outfile_path: Path = args.outfile
    with (sys.stdout if outfile_path == Path('-') else outfile_path.open(
            'w', encoding='utf-16')) as outfile:
        outfile.write('Windows Registry Editor Version 5.00\n\n')
        for service, startup in data.items():
            outfile.write(
                fr'[{args.target_hive_root}\ControlSet001\Services\{service}]'
                '\n'
                f'"Start"={startup}\n\n')


if __name__ == '__main__':
    # This is executed when run from the command line
    main()
