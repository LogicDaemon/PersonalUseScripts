@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
IF NOT DEFINED SysUtilsDir CALL "%~dp0..\_init.cmd"
IF NOT DEFINED SysUtilsDir SET "SysUtilsDir=%SystemDrive%\SysUtils"
IF NOT EXIST "%utilsdir%7za.exe" SET "utilsdir=%~dp0..\..\utils\"
)
IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%;%SysUtilsDir%\gnupg;%SysUtilsDir%\lbrisar;%SysUtilsDir%\ResKit;%SysUtilsDir%\Support Tools;%SysUtilsDir%\SysInternals;%SysUtilsDir%\kliu"
(
SET "PATH=%PATH%;%pathString%"
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z"
rem Importing REGs
FOR /R "%SysUtilsDir%\SysInternals" %%I IN (*.reg) DO REG IMPORT "%%~fI"

IF "%SysUtilsDelaySettings%"=="1" EXIT /B
REM Adding DLLs and CMDs to %PATH%
"%utilsdir%pathman.exe" /as "%pathString%"
)
