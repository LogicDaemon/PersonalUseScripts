@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
CALL "%~dp0download.cmd" || EXIT /B
CALL find7zexe.cmd x -aoa -y -o"%LOCALAPPDATA%\Programs\DesktopOK" "%~dp0DesktopOK_x64.zip"
)
