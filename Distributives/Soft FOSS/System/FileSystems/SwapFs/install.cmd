@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    CALL find7zexe.cmd
)
(
    FOR %%A IN (`DIR /B /O-D "%~dp0..\Windows Drivers Examples\www.acc.umu.se\~bosse\swapfs\swapfs-*.zip"`) DO (
        %exe7z% e -aou -y -o"%SystemRoot%\System32\drivers" -i!"%%~nA\swapfs.reg" -i!"%%~nA\sys\obj\fre\%PROCESSOR_ARCHITECTURE%\swapfs.sys" -- "%~dp0..\Windows Drivers Examples\www.acc.umu.se\~bosse\swapfs\%%~A"
    )
    regedit /s "%SystemRoot%\System32\drivers\swapfs.reg"
    SC START SwapFS
EXIT /B
)
