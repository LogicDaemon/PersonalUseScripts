@REM coding:OEM

CALL "%~dp0assoc_csvtsv_with_LO.cmd"

CALL _get_defaultconfig_source.cmd
IF NOT DEFINED DefaultsSource EXIT /B 1
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
IF NOT DEFINED exe7z SET exe7z=7z.exe

"%~dp0LibreOfficeCreateBackupDirs.ahk"
%exe7z% x -aoa "%DefaultsSource%" "LibreOffice*" -o"%ProgramFiles%"
