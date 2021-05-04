@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"

IF NOT EXIST r:\ EXIT /B
ATTRIB +I r:\*.* /S /D /L

MKDIR "r:\Temp\NVIDIA Corporation\NV_Cache"
COMPACT /U "r:\Temp\NVIDIA Corporation"

MKDIR "r:\Temp\obs-studio\crashes"
MKDIR "r:\Temp\obs-studio\plugin_config\obs-browsers"
MKDIR "r:\Temp\discord\Cache"
MKDIR "r:\Temp\discord\Code Cache"
MKDIR "r:\Temp\npm-cache"
MKDIR "r:\Temp\Steam\htmlcache"

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

REM if it's a link, it will be removed and re-created as an empty dir;
REM if it's a dir without contents, same
REM but if it's non-empty dir, it will stay as is
RD /Q "%LOCALAPPDATA%\Temp"
REM this is needed because now the directory will be moved to R:, and if it's a link to R:, that might break MOVE which will move files to themselves and then remove from source (but as it's linked to dest, remove that single copy altogether)
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
    RD /Q %1
    MKLINK /D %1 %2 || xln.exe -n %2 %1 || (
        RD /S /Q %1
        xln.exe -n %2 %1
    )
EXIT /B

:ReplaceDrive <var> <prefix> <path>
(
SET "%~1=%~2%~pn3"
EXIT /B
)
