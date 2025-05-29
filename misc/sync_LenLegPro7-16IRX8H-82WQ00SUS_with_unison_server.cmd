@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
@IF NOT DEFINED syncprog ( SET "syncprog=%unisontext%" ) ELSE IF NOT DEFINED filterSyncs IF NOT [%unisontext%]==[%syncprog%] SET "filterSyncs=1"
@(
    IF DEFINED filterSyncs IF NOT "%filterSyncs%"=="0" GOTO :ProceedWithPreSyncs
    FOR %%A IN ("%USERPROFILE%\.unison\Distributives@AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" -root "%unisonServer%d:/Distributives" %unisonopt%
    FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" %unisonopt%
EXIT /B
)
:ProceedWithPreSyncs
@(
    %unisontext% "Distributives_autosync_paths@AcerPH315-53-71HN" ^
        -root "%unisonServer%d:/Distributives" ^
        -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch
    DEL "%TEMP%\%~n0.list.txt" "%TEMP%\%~n0.listd.txt"
    FOR %%A IN ("%USERPROFILE%\.unison\Distributives@AcerPH315-53-71HN.prf") DO @(
        <NUL %unisontext% "%%~nA" -root "%unisonServer%d:/Distributives" "-auto=false" || ECHO "%%~nA">>"%TEMP%\%~n0.listd.txt"
    )
    FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO @(
        <NUL %unisontext% "%%~nA" "-auto=false" || ECHO "%%~nA">>"%TEMP%\%~n0.list.txt"
    )
    FOR /F "usebackq delims=" %%A IN ("%TEMP%\%~n0.listd.txt") DO %syncprog% "%%~A" -root "%unisonServer%d:/Distributives" %unisonopt%
    FOR /F "usebackq delims=" %%A IN ("%TEMP%\%~n0.list.txt") DO %syncprog% "%%~A" %unisonopt%
    DEL "%TEMP%\%~n0.list.txt" "%TEMP%\%~n0.listd.txt"
    EXIT /B
)
