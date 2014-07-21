@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET "distDir=%~dp0"
SET "distFName=Thunderbird Setup *.exe"
)

FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "WinVer=%%~I"
IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" (
    SET "distDir=\\Srv0.office0.mobilmir\Distributives\Soft_old\Network\Mail News\Mozilla Thunderbird\W2K\"
    SET "distFName=Thunderbird Setup 12.0.1 ru.exe"
    GOTO :Found
)

FOR /F "usebackq delims=" %%I IN (`DIR /B /O-D "%distDir%%distFName%"`) DO (
    SET distFName=%%~I
    GOTO :Found
)
ECHO Distributive not found!
EXIT /B 1

:Found
(
ENDLOCAL
SET distFullPath=%distDir%%distFName%
)
(
ECHO Distributive: %distFullPath%
EXIT /B 0
)
