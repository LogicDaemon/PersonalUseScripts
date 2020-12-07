@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL _unison_get_command.cmd || EXIT /B
    IF NOT DEFINED unisontext EXIT /B 1
    IF "%~1"=="" (
        IF NOT DEFINED unisonopt SET unisonopt=-auto
        SET skipPresyncs=
    ) ELSE (
        SET unisonopt=%unisonopt% %*
        SET skipPresyncs=1
    )
)
IF NOT DEFINED syncprog SET syncprog=%unisontext%
(
    PUSHD "%TEMP%" || EXIT /B
    START "Distributives Unison server" /B %unisontext% -socket 10355
    PING -n 2 127.0.0.1 >NUL
    IF NOT DEFINED skipPresyncs (
        ECHO Synchronizing Soft and drivers
        %unisontext% Distributives192.168.36.1 -path Soft -path Drivers -path "Soft com freeware" -path "Soft com license" -path "Soft FOSS" -path "Soft private use only" %unisonopt%
        ECHO Synchronizing config
        %unisontext% Distributives192.168.36.1 -path config %unisonopt%
        ECHO Synchronizing remaining
    )
    %syncprog% Local_Scripts192.168.36.1 %unisonopt%
    %syncprog% Distributives192.168.36.1 %unisonopt% -killserver

    ENDLOCAL
EXIT /B
)

rem %syncprog% Distributives -root \\192.168.36.1\Distributives %unisonopt% -killserver

rem     %unisontext% Distributives192.168.36.1 -killserver -testserver -silent
