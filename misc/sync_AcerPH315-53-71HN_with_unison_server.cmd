@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED skipPresyncs IF NOT DEFINED unisontext CALL _unison_get_command.cmd
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
@IF NOT DEFINED syncprog SET "syncprog=%unisontext%"
@(

    IF NOT DEFINED skipPresyncs (
        ECHO Synchronizing Soft and drivers
        %unisontext% Distributives_u327016.your-storagebox.de %unisonopt% -batch -path Soft -path Drivers -path "Soft com freeware" -path "Soft com license" -path "Soft FOSS" -path "Soft private use only"
        ECHO Synchronizing remaining
    )
    %syncprog% Distributives_u327016.your-storagebox.de %unisonopt%
)
