@REM coding:OEM
@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET tempdest=%TEMP%\AdaptecASPI4.71a2

7za x -aoa "%srcpath%ASPI 4.71a2.7z" -o"%tempdest%"
PUSHD "%tempdest%"
aspiinst.exe /FORCE /SILENT
POPD
RD /S /Q "%tempdest%"
