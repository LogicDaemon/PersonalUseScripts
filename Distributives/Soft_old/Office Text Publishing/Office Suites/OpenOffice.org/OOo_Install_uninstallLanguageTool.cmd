@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

IF NOT DEFINED ErrorCmd SET ErrorCmd=IF ERRORLEVEL 2 EXIT /B 2

IF "%OOoBinDirectory%"=="" CALL _OOo_get_directories.cmd
IF "%OOoBinDirectory%"=="" CALL "%~dp0_corrections\_OOo_get_directories.cmd"
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles^(x86^)%
IF "%OOoBinDirectory%"=="" (
    SET OOoBinDirectory=%ProgramFiles%\OpenOffice.org 3\program\
)
SET unopkgexe=%OOoBinDirectory%unopkg

"%unopkgexe%" remove --shared unopkg remove --shared "org.openoffice.languagetool.oxt"||%ErrorCmd%
