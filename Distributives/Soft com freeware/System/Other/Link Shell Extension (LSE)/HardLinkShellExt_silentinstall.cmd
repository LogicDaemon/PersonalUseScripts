@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

IF DEFINED OS64Bit (
    "%~dp0nt\hardlinkshellext\HardLinkShellExt_X64.exe" /S /Language=English
) ELSE (
    "%~dp0nt\hardlinkshellext\HardLinkShellExt_win32.exe" /S /Language=English
)
)
