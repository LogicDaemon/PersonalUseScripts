(
@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF "%utilsdir%"=="" SET "utilsdir=%~dp0..\utils\"
SET "lProgramFiles=%ProgramFiles%"
IF DEFINED ProgramFiles^(x86^) SET "lProgramFiles=%ProgramFiles(x86)%"
)
(
"%utilsdir%7za.exe" x -r -aoa -o"%lProgramFiles%\%~n0" -- "%srcpath%%~n0.7z"
START "" /B /WAIT /D "%lProgramFiles%\%~n0" /I %comspec% /C "%lProgramFiles%\%~n0\Install.cmd"
)
