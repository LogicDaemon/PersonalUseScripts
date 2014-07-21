@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"

IF NOT EXIST R:\ EXIT /B
COMPACT /C "R:"
MKDIR R:\Temp\NVIDIA Corporation
COMPACT /U "R:\Temp\NVIDIA Corporation"
ATTRIB +I R:\*.* /S /D /L

SET "USERPROFILE=d:\Users\LogicDaemon"
)
(
SET "APPDATA=%USERPROFILE%\AppData\Roaming"
SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
)
CALL :ReplaceDrive RDLOCALAPPDATA R: "%LOCALAPPDATA%"

rem CALL :LinkBack "%LOCALAPPDATA%\Microsoft\Windows\Explorer" "r:\AppData\Local\Microsoft\Windows\Explorer"
rem CALL :LinkBack "%LOCALAPPDATA%\Microsoft\Windows\INetCache" "r:\AppData\Local\Microsoft\Windows\INetCache"
rem CALL :LinkBack "%LOCALAPPDATA%\Microsoft\Windows\Notifications" "r:\AppData\Local\Microsoft\Windows\Notifications"
rem CALL :LinkBack "%LOCALAPPDATA%\Microsoft\Windows\WebCache" "r:\AppData\Local\Microsoft\Windows\WebCache"

rem CALL :LinkBack "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" "r:\AppData\Local\Google\Chrome\User Data\Default\Cache"
rem CALL :LinkBack "%LOCALAPPDATA%\Google\Chrome\User Data\Profile 3\Cache" "r:\AppData\Local\Google\Chrome\User Data\Profile 3\Cache"
rem CALL :LinkBack "%LOCALAPPDATA%\Chromium\User Data\Default\Cache" "r:\AppData\Local\Google\Chromium\User Data\Default\Cache"
rem CALL :LinkBack "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\ka3nrsws.default\Cache" "r:\AppData\Local\Mozilla\Firefox\Cache"
rem CALL :LinkBack "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\ka3nrsws.default\cache2" "r:\AppData\Local\Mozilla\Firefox\Cache2"

RD /Q "%LOCALAPPDATA%\Temp"
MKDIR "%LOCALAPPDATA%\Temp"
CALL :LinkBack "%LOCALAPPDATA%\Temp" "r:\Temp"

EXIT /B

:LinkBack <source> <destination>
    IF EXIST "%~1\*" IF NOT EXIST %2 (
	IF NOT EXIST "%~dp2" MKDIR "%~dp2"
	IF NOT EXIST "%~dp2" EXIT /B
	MOVE /Y "%~1" "%~2"
    )
    IF NOT EXIST "%~2" MKDIR "%~2"
    IF NOT EXIST "%~2" EXIT /B
    
    xln.exe -n "%~2" "%~1"
    IF ERRORLEVEL 1 RD /S /Q "%~1" & xln.exe -n "%~2" "%~1"
EXIT /B

:ReplaceDrive <var> <prefix> <path>
(
SET "%~1=%~2%~pn3"
EXIT /B
)
