(
@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF "%utilsdir%"=="" SET utilsdir=%~dp0..\utils\

SET "RunPathVar=ProgramFiles"
SET "lProgramFiles=%ProgramFiles%"
IF NOT DEFINED ProgramFiles^(x86^) GOTO :Skip64bitEnv
SET "lProgramFiles=%ProgramFiles(x86)%"
SET "RunPathVar=ProgramFiles^(x86^)"
)
:Skip64bitEnv
(
SET xlnexe=%utilsdir%xln.exe
SET exe7z=%utilsdir%7za.exe
)
(
"%exe7z%" x -r -aoa -o"%lProgramFiles%\Notepad2" -- "%srcpath%%~n0.7z"

ASSOC .txt=notepad2-txtfile
FTYPE notepad2-txtfile=^"%%%RunPathVar%%%\Notepad2\Notepad2.exe^" %%1

REG ADD "HKEY_CLASSES_ROOT\*\OpenWithList\Notepad2.exe" /f
REG ADD "HKEY_CLASSES_ROOT\Applications\notepad2.exe\shell\open\command" /ve /d """"%%%RunPathVar%%%\Notepad2\notepad2.exe""" """%%1"""" /f
REG ADD "HKEY_CLASSES_ROOT\Applications\notepad2.exe\shell\edit\command" /ve /d """"%%%RunPathVar%%%\Notepad2\notepad2.exe""" """%%1"""" /f
)
