@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
CALL find7zexe.cmd
)
FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%~dp0KeePass-1.*.zip"`) DO (
    %exe7z% x -aoa -y -o"%LocalAppData%\Programs\%%~nA" -- "%~dp0%%A" || EXIT /B
    MKLINK /J "%LocalAppData%\Programs\KeePass" "%LocalAppData%\Programs\%%~nA" || (
        RD "%LocalAppData%\Programs\KeePass" && MKLINK /J "%LocalAppData%\Programs\KeePass" "%LocalAppData%\Programs\%%~nA"
    )
    EXIT /B
)
