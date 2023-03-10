@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    CALL "%LocalAppData%\Scripts\software_update\Downloader\_GetWorkPaths.cmd"

    FOR /R "%~dp0.." %%A IN (".Distributives_Update_Run.*.cmd") DO IF EXIST %%A (
        START "" /LOW /D "%%~dpA" /B %comspec% /C ""%%~A""
    )
)
