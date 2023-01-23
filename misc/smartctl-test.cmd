@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq tokens=1" %%A IN (`smartctl.exe --scan`) DO (
        smartctl.exe -t long %%A
    )
)

