@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "dest=d:\Distributives\Soft com freeware\System\Virtual Machines Sandboxes\.NET\addons"
)
(
MKDIR "%dest%"
XCOPY "%~dp0CRRedist2005_x86.msi" "%dest%" /E /I /Q /G /H /R /K /O /Y /B
XCOPY "%~dp0install_CRRedist2005_x86.cmd" "%dest%" /E /I /Q /G /H /R /K /O /Y /B
PUSHD "%dest%" && ( CALL "%dest%\install_CRRedist2005_x86.cmd" & POPD )
)
