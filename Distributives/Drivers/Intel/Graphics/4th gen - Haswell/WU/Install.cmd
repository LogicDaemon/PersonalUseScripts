@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "tempdst=%TEMP%\%~n0 Intel Graphics"
rem does not work for UNC paths: SET "localdist=d:%~p0"
IF NOT DEFINED ErrorCmd SET "ErrorCmd=PAUSE"
IF NOT DEFINED exe7z CALL find7zexe.cmd

SET "OSCapacity=32-bit"
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSCapacity=64-bit"
IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSCapacity=64-bit"
)
(
%exe7z% e -r -o"%tempdst%" -- "%srcpath%dpinst.7z"  "dpinst.xml" "%OSCapacity%\*"||%ErrorCmd%
%exe7z% x -r -o"%tempdst%\*" -- "%srcpath%%OSCapacity%\*.cab"||%ErrorCmd%
START "" /WAIT /D "%tempdst%" dpinst.exe||%ErrorCmd%
RD /S /Q "%tempdst%"
EXIT /B
)
