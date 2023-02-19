@REM coding:OEM
@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF NOT DEFINED RunInteractiveInstalls SET RunInteractiveInstalls=1

SET dest=%SystemRoot%\System32
XCOPY /D /Y "%srcpath%FrogASPI.dll" "%dest%"
XCOPY /D /Y "%srcpath%FrogRights.exe" "%dest%"
IF "%RunInteractiveInstalls%"=="1" "%dest%\FrogRights.exe"
