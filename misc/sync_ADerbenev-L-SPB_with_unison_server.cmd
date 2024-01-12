@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
    IF NOT DEFINED filterSyncs (
        IF "%unisonopt%"=="" SET "filterSyncs=1"
        IF "%unisonopt%"=="-auto" SET "filterSyncs=1"
    )
)
@IF NOT DEFINED syncprog SET "syncprog=%unisontext%"
@(
    IF DEFINED filterSyncs IF NOT "%filterSyncs%"=="0" (
        %unisontext% Distributives_AcerPH315-53-71HN -path "Soft/Keyboard Tools/AutoHotkey/ver.zip.txt" -path "Developement/Versioning/git/latest_assets.json" -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch
        DEL "%TEMP%\%~n0.list.txt"
        FOR %%A IN ("%USERPROFILE%\.unison\*_AcerPH315-53-71HN.prf") DO @(
            <NUL %unisontext% "%%~nA" "-auto=false" || ECHO "%%~nA">>"%TEMP%\%~n0.list.txt"
        )
        FOR /F "usebackq delims=" %%A IN ("%TEMP%\%~n0.list.txt") DO %syncprog% "%%~A" %unisonopt%
        DEL "%TEMP%\%~n0.list.txt"
    ) ELSE (
        FOR %%A IN ("%USERPROFILE%\.unison\*_AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" %unisonopt%
    )
EXIT /B
)
