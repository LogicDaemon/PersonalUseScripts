@REM coding:OEM
REM Template to install preinstalled and working-without-install software
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

REM IF NOT DEFINED APPDATA SET APPDATA=%USERPROFILE%\Application Data

IF NOT EXIST "%ProgramFiles%\%~n0" MKDIR "%ProgramFiles%\%~n0"
compact /C /S:"%ProgramFiles%\%~n0" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles%\%~n0"

REM IF "%SetUserSettings%"=="1" (
REM     PUSHD "%ProgramFiles%\%~n0"
REM     IF EXIST "%~n0.ini" REN "%~n0.ini" "%~n0.ini.bak"
REM     COPY /Y /B "%~n0.distributed.ini" "%~n0.ini"
REM     SET srcpathbak=%srcpath%
REM     SET srcpath=
REM     CALL UserInstall.cmd
REM     SET srcpath=%srcpathbak%
REM     SET srcpathbak=
REM     POPD
REM     REM Getting startup folder location
REM     FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Start Menu"`) DO SET HKCUStartMenu=%%J
REM     "%utilsdir%xln.exe" -w -wd "%programfiles%\%~n0" "%programfiles%\%~n0\%~n0.exe" "%HKCUStartMenu%\%~n0.lnk"
REM )
REM IF "%SetSystemSettings%"=="1" (
REM     REM Getting startup folder location
REM     FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Start Menu"`) DO SET HKLMStartMenu=%%J
REM     "%utilsdir%xln.exe" -w -wd "%programfiles%\%~n0" "%programfiles%\%~n0\%~n0.exe" "%HKLMStartMenu%\%~n0.lnk"
REM )
