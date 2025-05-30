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
    %unisontext% Distributives_autosync_paths@AcerPH315-53-71HN ^
        -root "%unisonServer%d:/Distributives" ^
        -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch

    SET name=Unison
    CALL :CheckSync "%unisonServer%%USERPROFILE:\=/%\.unison" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" -ignorenot "Name *.prf" -ignore "Name *"
    SET name=Distributives
    CALL :CheckSync "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"
    SET name=ahkLib
    CALL :CheckSync "%USERPROFILE%\Documents\AutoHotkey\Lib" "\\AcerPH315-53-71HN\Users\LogicDaemon\Dropbox\Projects\AutoHotkey\Lib"
    SET name=Scripts
    CALL :CheckSync "aderbenev_Scripts@AcerPH315-53-71HN" -root "%unisonServer%%LOCALAPPDATA:\=/%\Scripts"

    rem IF DEFINED sync_ahkLib %syncprog% %sync_ahkLib% %unisonopt%
    rem IF DEFINED sync_Scripts %syncprog% %sync_Scripts% %unisonopt%
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
