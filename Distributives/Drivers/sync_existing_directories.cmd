@ECHO OFF

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 echo Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

FOR /D %%I IN (*.*) DO CALL :CheckOptFileAndSync "%%I"

GOTO :EOF
:CheckOptFileAndSync
ECHO Syncing %~1
SET moreunisonopt=
IF EXIST "%~1\unison_opt.txt" FOR /F "usebackq delims=" %%k IN ("%~1\unison_opt.txt") DO SET moreunisonopt=%%k
CALL unisont driversM -path %1 %unisonopt% %moreunisonopt%

:EOF
