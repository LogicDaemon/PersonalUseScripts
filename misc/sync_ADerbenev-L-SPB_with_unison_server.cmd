@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED syncprog CALL _unison_get_command.cmd
)
IF NOT DEFINED syncprog (
    SET "syncprog=%unisontext%"
) ELSE (
    IF NOT DEFINED filterSyncs IF [%unisontext%] NEQ [%syncprog%] SET "filterSyncs=1"
)
(
    %unisontext% Distributives_autosync_paths@AcerPH315-53-71HN ^
        -root "%unisonServer%d:/Distributives" ^
        -prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch
    SET name=Unison
    CALL :CheckSync "%unisonServer%%USERPROFILE:\=/%/My SecuriSync/config/.unison/default" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison/default"
    CALL :CheckSync "%unisonServer%%USERPROFILE:\=/%/My SecuriSync/config/.unison" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" -ignore "Regex [^.]+" -ignore "Name .nomedia" -ignore "Name unison.log"
    SET name=.continue
    CALL :CheckSync "%unisonServer%d:/Users/LogicDaemon/.continue" "\\AcerPH315-53-71HN\Users\LogicDaemon\Dropbox\config\#Home\.continue"
    SET name=Distributives
    CALL :CheckSync "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"
    SET name=ahkLib
    CALL :CheckSync "%USERPROFILE%\Documents\AutoHotkey\Lib" "\\AcerPH315-53-71HN\Users\LogicDaemon\Dropbox\Projects\AutoHotkey\Lib"
    SET name=Scripts
    CALL :CheckSync "aderbenev_Scripts@AcerPH315-53-71HN" -root "%unisonServer%%LOCALAPPDATA:\=/%\Scripts"

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
