@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "distBaseDir=Soft FOSS\Tests Benchmarks HardWareMonitors Diagnostics\LibreHardwareMonitor"
    SET "distFileMask=LibreHardwareMonitor-*.zip"
    SET "destbase=%LocalAppData%\Programs"
    SET "destlink=%LocalAppData%\Programs\LibreHardwareMonitor"
)
(
    CALL _Distributives.find_subpath.cmd Distributives "%distBaseDir%\%distFileMask%" || GOTO :afterInstalling
    FOR /F "usebackq delims=" %%A IN ("%destlink%\thisVersion.txt") DO @IF NOT DEFINED installedVersion SET "installedVersion=%%~A"
)
IF DEFINED distFileMask FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "%Distributives%\%distBaseDir%\%distFileMask%"`) DO @(
    IF "%%~nA"=="%installedVersion%" GOTO :afterInstalling
    CALL :install "%%~A" && GOTO :afterInstalling
)
:afterInstalling
(
    START "" /D "%destlink%" "%destlink%\LibreHardwareMonitor.exe" %*
    EXIT /B
)

:install
IF NOT DEFINED exe7z CALL find7zexe.cmd
(
    %exe7z% x -aoa -y -o"%destbase%\%~n1" -- "%Distributives%\%distBaseDir%\%~1" || EXIT /B
    (
        ECHO %~n1
    )>"%dest%\thisVersion.txt"
    COMPACT /C /EXE:LZX /S:"%destbase%\%~n1"
    MOVE "%destlink%" "%destlink%.bak"
    MKLINK /D "%destlink%" "%destbase%\%~n1" || MKLINK /J "%destlink%" "%destbase%\%~n1"
    COPY /Y "%destlink%.bak\LibreHardwareMonitor.config" "%destlink%\LibreHardwareMonitor.config"
    RD "%destlink%.bak"
    EXIT /B
)
