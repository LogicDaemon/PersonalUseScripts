@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
@ECHO OFF
    %SystemRoot%\System32\fltmc.exe >nul 2>&1 && GOTO :AsAdmin
    ECHO This script requres administrator rights to run
)
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c """"%~f0"" %*"" ::","","runas",1)(window.close)&&exit
@(
    PING -n 30 127.0.0.1 >NUL
    EXIT /B
)
:AsAdmin
FOR %%I IN ("%~dp0*.vhd") DO powershell -c "Mount-DiskImage '%~fI'"
