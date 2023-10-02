@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED hostname CALL :ReadRegHostname hostname

    CALL _unison_get_command.cmd || EXIT /B
    IF NOT DEFINED unisontext EXIT /B 1
    IF "%~1"=="" (
        IF NOT DEFINED unisonopt SET unisonopt=-auto
        SET skipPresyncs=1
    ) ELSE (
        SET unisonopt=%unisonopt% %*
        SET skipPresyncs=1
    )
)
IF NOT DEFINED syncprog SET "syncprog=%unisontext%"
(
PUSHD "%TEMP%" || EXIT /B
START "Distributives Unison server" /MIN %unisontext% -socket 10355
PING -n 2 127.0.0.1 >NUL

START "" /B /WAIT %comspec% /C "%~dp0sync_%hostname%_with_unison_server.cmd"

REM lock files remain if started too soon
@PING 127.0.0.1 -n 5 >NUL
%unisontext% "%TEMP%" "socket://localhost:10355/%TEMP:\=/%" -testserver -killserver
EXIT /B
)
:ReadRegHostname <var>
(
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "%~1=%%~J"
EXIT /B
)
