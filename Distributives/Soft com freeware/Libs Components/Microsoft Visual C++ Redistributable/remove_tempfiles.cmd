@REM coding:OEM
@ECHO OFF

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 echo Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

:AskDriveLetter
SET /P Drive=Drive letter where installer put tempfiles: 
FOR /F "usebackq" %%I IN ("%srcpath%tempfiles.txt") DO IF NOT EXIST "%Drive%:\%%I" (
    ECHO File not exist: %Drive%:\%%I
    GOTO :AskDriveLetter
)

FOR /F "usebackq" %%I IN ("%srcpath%tempfiles.txt") DO DEL "%Drive%:\%%I"
