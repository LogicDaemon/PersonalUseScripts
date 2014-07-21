@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

FOR %%A IN ("%LocalAppData%\Programs\SysUtils\SysInternals\*.*") DO START "" /B /D "%%~dpA" CURL -ROJ -z "%%~A" "https://live.sysinternals.com/%%~nxA"
)
