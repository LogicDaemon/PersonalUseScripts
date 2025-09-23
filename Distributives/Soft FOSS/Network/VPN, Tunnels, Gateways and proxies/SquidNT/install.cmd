@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

CALL find7zexe.cmd || ( PAUSE & EXIT /B )

%SystemRoot%\System32\net.exe stop squid
)
(
%exe7z% x -aoa -o"c:\squid" -- "%~dp0squid.2.7.7z"
PUSHD "C:\squid\sbin" && (
    CALL "C:\squid\sbin\install.cmd"
    POPD
)
EXIT /B
)
:GetDir <var> <path>
(
    SET "%~1=%~dp2"
EXIT /B
)
