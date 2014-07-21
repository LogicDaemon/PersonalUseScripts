@REM coding:OEM
CALL _get_defaultconfig_source.cmd
IF NOT DEFINED DefaultsSource EXIT /B 1

IF "%OOoBaseDirectory%"=="" CALL _OOo_get_directories.cmd
IF "%OOoBaseDirectory%"=="" CALL %~dp0_corrections\_OOo_get_directories.cmd
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles^(x86^)%
IF "%OOoBaseDirectory%"=="" (
    SET OOoBaseDirectory=%ProgramFiles%\
)

7z x -aoa -r0 "%DefaultsSource%" "OpenOffice.org 3\share\*" -o"%OOoBaseDirectory%"
