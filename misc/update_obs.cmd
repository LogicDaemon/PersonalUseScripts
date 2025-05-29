@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL "%~dp0_Distributives.find_subpath.cmd" Distributives "Soft FOSS\MultiMedia\Capture\OBS\install_to_LOCALAPPDATA.cmd"
    IF NOT DEFINED Distributives (
        ECHO Could not find Distributives directory with OBS
        EXIT /B 1
    )
)
(
    FOR %%A IN ("%Distributives%\Soft FOSS\MultiMedia\Capture\OBS\.Distributives_Update_Run.*.cmd") DO START "" /B /WAIT %comspec% /C ""%%~A""
    CALL "%Distributives%\Soft FOSS\MultiMedia\Capture\OBS\install_to_LOCALAPPDATA.cmd"
)
