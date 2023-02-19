@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "cppdistpath=%~dp0..\..\..\wsusoffline\client\cpp"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "inst64bit=1"
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "inst64bit=1"
)
(
IF NOT DEFINED inst64bit GOTO :CPPInst32bit

:CPPInst64bit
"%cppdistpath%\vcredist2005_x64.exe" /Q /r:n
"%cppdistpath%\vcredist2008_x64.exe" /q /r:n
"%cppdistpath%\vcredist2010_x64.exe" /q /norestart
"%cppdistpath%\vcredist2012_x64.exe" /q /norestart
rem wsusoffline doesn't download the latest version of 2013 redistributable
"2013 KB3138367\vcredist_x64.en-US.exe" /q /norestart

rem https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads
rem Note Visual C++ 2015, 2017 and 2019 all share the same redistributable files.
"%cppdistpath%\vcredist2019_x64.exe" /q /norestart

:CPPInst32bit
"%cppdistpath%\vcredist2005_x86.exe" /Q /r:n
"%cppdistpath%\vcredist2008_x86.exe" /q /r:n
"%cppdistpath%\vcredist2010_x86.exe" /q /norestart
"%cppdistpath%\vcredist2012_x86.exe" /q /norestart
"2013 KB3138367\vcredist_x86.en-US.exe" /q /norestart
"%cppdistpath%\vcredist2019_x86.exe" /q /norestart

CALL "%~dp0remove_tempfiles.cmd"
)
