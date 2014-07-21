@REM coding:OEM
VERIFY OTHER 2>NUL
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF NOT EXIST "%ProgramFiles%\%~n0" MKDIR "%ProgramFiles%\%~n0"
compact /C /S:"%ProgramFiles%\%~n0" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles%\%~n0"
