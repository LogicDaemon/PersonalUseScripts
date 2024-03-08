@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

SET "srcpath=%~dp0"
START "" /B /WAIT py -O "%~dp0download.py" -t "windows/64-bit/compressed-7z"
)
