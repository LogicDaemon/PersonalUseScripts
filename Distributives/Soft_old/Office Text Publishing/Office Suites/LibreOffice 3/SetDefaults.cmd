@REM coding:OEM

CALL "%~dp0assoc_csvtsv_with_LO.cmd"

CALL _get_defaultconfig_source.cmd
IF NOT DEFINED DefaultsSource EXIT /B 1
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%

"%~dp0LibreOfficeCreateBackupDirs.ahk"
7z x -aoa "%DefaultsSource%" "LibreOffice*" -o"%ProgramFiles%"
