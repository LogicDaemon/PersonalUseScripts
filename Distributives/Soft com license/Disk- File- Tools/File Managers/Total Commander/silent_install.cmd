@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT DEFINED dirDist SET "dirDist=%~dp0"
    REM https://www.ghisler.ch/wiki/index.php?title=How_to_make_installation_fully_automatic%3F

    IF "%~1"=="" (
        SET "OSWordSize=32"
        IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSWordSize=64"
        IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSWordSize=64"
    ) ELSE (
        SET "OSWordSize=%~1"
    )

    SET "installOptns=/A1H0L1M0G0D0U1K0"
)
@FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%dirDist%tcmd*x%OSWordSize%.exe"`) DO (
    "%dirDist%%%~nxA" %installOptns%
    EXIT /B
)
