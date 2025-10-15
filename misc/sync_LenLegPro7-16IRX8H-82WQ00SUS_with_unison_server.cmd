@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
IF NOT DEFINED syncprog ( SET "syncprog=%unisontext%" ) ELSE (
    IF NOT DEFINED filterSyncs IF NOT [%unisontext%]==[%syncprog%] SET "filterSyncs=1"
)
(
    IF DEFINED filterSyncs IF NOT "%filterSyncs%"=="0" GOTO :ProceedWithPreSyncs
    FOR %%A IN ("%USERPROFILE%\.unison\Distributives@AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" -root "%unisonServer%d:/Distributives" %unisonopt%
    FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO %syncprog% "%%~nA" %unisonopt%
EXIT /B
)
:ProceedWithPreSyncs
(
    %unisontext% "Distributives_autosync_paths@AcerPH315-53-71HN" ^
        -root "%unisonServer%d:/Distributives" ^
        -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch

    SET "name=Unison" & CALL :CheckSync "%unisonServer%%USERPROFILE:\=/%\.unison" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" -ignore "Name *" -ignorenot "Name *.prf" -ignorenot "Name default"
    SET "name=Distributives" & CALL :CheckSync "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"

    FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO @(
        SET "name=%%~nA"
        CALL :CheckSync "%%~nA" "-auto=false"
    )

    FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO %syncprog% %%B %unisonopt%
    EXIT /B
)
:CheckSync
(
    IF DEFINED filterSyncs (
        <NUL %unisontext% %* "-auto=false" || SET "sync_%name%=%*"
    ) ELSE (
        VERIFY INVALID 2>NUL
    ) || SET "sync_%name%=%*"
    EXIT /B
)
