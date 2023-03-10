@REM coding:OEM
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

"%srcpath%Windows2000-KB842773-x86-RUS.EXE" -u -n -z||PAUSE
7z x -aoa "%srcpath%winhttp5.7z" -o"%SystemRoot%\System32\"||PAUSE
proxycfg.exe -u||PAUSE
