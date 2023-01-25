@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

CALL "%~dp0_Distributives.find_subpath.cmd" Distributives "Soft FOSS\MultiMedia\Capture\OBS\download.cmd"
)
@(
CALL "%Distributives%\Soft FOSS\MultiMedia\Capture\OBS\download.cmd"
CALL "%Distributives%\Soft FOSS\MultiMedia\Capture\OBS\install_to_LOCALAPPDATA.cmd"
)
