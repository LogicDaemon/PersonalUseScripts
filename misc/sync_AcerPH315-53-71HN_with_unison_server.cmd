@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
    SET "filterSyncs="
    IF "%unisonopt%"=="" SET "filterSyncs=1"
    IF "%unisonopt%"=="-auto" SET "filterSyncs=1"
)
@IF NOT DEFINED syncprog SET "syncprog=%unisontext%"
@(
    %unisontext% Distributives_u327016.your-storagebox.de -path "Soft/Keyboard Tools/AutoHotkey/ver.zip.txt" -prefer "socket://localhost:10355/v:/Distributives" -auto -batch
    IF DEFINED filterSyncs (
        ECHO Checking for changes
        <NUL %unisontext% Distributives_u327016.your-storagebox.de "-auto=false" && (
            ECHO No changes, exiting
            PING 127.0.0.1 >NUL
            EXIT /B
        )
    ) ELSE (
        ECHO Synchronizing Soft and drivers without updates
        %unisontext% Distributives_u327016.your-storagebox.de %unisonopt% -batch -path Soft -path Drivers -path "Soft com freeware" -path "Soft com license" -path "Soft FOSS" -path "Soft private use only" -noupdate socket://localhost:10355/v:/Distributives
    )
    ECHO Starting full sync with manual confirmation
    %syncprog% Distributives_u327016.your-storagebox.de %unisonopt%
)
