@REM coding:OEM
REM Script to install preinstalled and working-without-install software
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
IF NOT EXIST "%ProgramFiles%\%~n0" MKDIR "%ProgramFiles%\%~n0"
compact /C /S:"%ProgramFiles%\%~n0" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles%\%~n0"

REM TODO: Allow users to access to scdwriter.ini

IF "%SetSystemSettings%"=="1" (
    PUSHD "%ProgramFiles%\%~n0"
    SET srcpathbak=%srcpath%
    SET srcpath=
    CALL install.cmd
    SET srcpath=%srcpathbak%
    SET srcpathbak=
    POPD
)
