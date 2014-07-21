@REM coding:OEM
REM Script to install preinstalled and working-without-install software
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF NOT EXIST "%ProgramFiles%\%~n0" MKDIR "%ProgramFiles%\%~n0"
compact /C /S:"%ProgramFiles%\%~n0" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles%\%~n0"
