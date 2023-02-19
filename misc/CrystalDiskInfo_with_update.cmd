@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "distBaseDir=Soft FOSS\Tests Benchmarks HardWareMonitors Diagnostics\Crystal DiskInfo"
    SET "distFileMask=CrystalDiskInfo*.zip"
    SET "dest=%LocalAppData%\Programs\CrystalDiskInfo"
)
(
    CALL _Distributives.find_subpath.cmd Distributives "%distBaseDir%\%distFileMask%" || GOTO :afterInstalling
    FOR /F "usebackq delims=" %%A IN ("%dest%\thisVersion.txt") DO @IF NOT DEFINED installedVersion SET "installedVersion=%%~A"
)
IF DEFINED distFileMask FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "%Distributives%\%distBaseDir%\%distFileMask%"`) DO @(
    IF "%%~nA"=="%installedVersion%" GOTO :afterInstalling
    CALL :install "%%~A" && GOTO :afterInstalling
)
:afterInstalling
(
    START "" /D "%dest%" "%dest%\DiskInfo64.exe" %*
    EXIT /B
)

:install
IF NOT DEFINED exe7z CALL find7zexe.cmd
(
    %exe7z% x -aoa -x!DiskInfo32.exe -x!DiskInfoA*.exe -o"%dest%" -- "%Distributives%\%distBaseDir%\%~1" || EXIT /B
    (
        ECHO %~n1
    )>"%dest%\thisVersion.txt"
    COMPACT /C /EXE:LZX "%dest%\*.exe"
    COMPACT /C /EXE:LZX /S:"%dest%" *.exe *.txt
    COMPACT /C /EXE:LZX /S:"%dest%\CdiResource"
    EXIT /B
)
