@(REM coding:CP866
IF NOT DEFINED SysUtilsDir CALL "%~dp0..\_init.cmd"
IF NOT DEFINED SysUtilsDir SET "SysUtilsDir=%SystemDrive%\SysUtils"
IF NOT EXIST "%utilsdir%7za.exe" SET "utilsdir=%~dp0..\..\utils\"
rem TODO: read required paths to add to env-PATH from 7z
)
IF NOT DEFINED pathString SET "pathString=%SysUtilsDir%\libs;%SysUtilsDir%\libs\GTK+\lib;%SysUtilsDir%\libs\OpenSSL;%SysUtilsDir%\libs\OpenSSL\bin"
(
SET "PATH=%PATH%;%pathString%"
"%utilsdir%7za.exe" x -r -aoa -o"%SysUtilsDir%" "%~dpn0.7z"
IF "%SysUtilsDelaySettings%"=="1" EXIT /B
REM Adding DLLs and CMDs to %PATH%
"%utilsdir%pathman.exe" /as "%pathString%"

REM GTK+ post-install script works only if gtk-libraries are in path
REM This is done least because of problem with this when using 64-bit OS because of brackets (x86) in %path%
CALL "%SysUtilsDir%\libs\GTK+\gtk2-runtime\gtk-postinstall.bat"
)
