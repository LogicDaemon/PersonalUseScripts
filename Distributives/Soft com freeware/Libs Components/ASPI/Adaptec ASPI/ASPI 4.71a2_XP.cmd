@REM coding:OEM
@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET tempdest=%TEMP%\AdaptecASPI4.71a2

7z x -aoa "%srcpath%ASPI 4.71a2.7z" -o"%tempdest%"
PUSHD "%tempdest%"
CALL install.bat xp32
POPD
RD /S /Q "%tempdest%"
