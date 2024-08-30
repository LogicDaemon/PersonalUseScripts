@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
@(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    py "%~dp0download.py"
)
