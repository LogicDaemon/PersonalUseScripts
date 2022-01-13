@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED skipPresyncs (
        ECHO Synchronizing Soft and drivers
        %unisontext% Distributives192.168.36.1 -path Soft -path Drivers -path "Soft com freeware" -path "Soft com license" -path "Soft FOSS" -path "Soft private use only" %unisonopt%
        ECHO Synchronizing config
        %unisontext% Distributives192.168.36.1 -path config %unisonopt%
        ECHO Synchronizing remaining
    )
    %syncprog% Local_Scripts192.168.36.1 %unisonopt%
    %syncprog% Distributives192.168.36.1 %unisonopt%
)
