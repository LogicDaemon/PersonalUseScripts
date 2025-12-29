@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL find7zexe.cmd
    CALL :InitRemembering
    FOR %%A IN ("%~dp0bt-*.zip") DO CALL :RememberIfLatest dstfname "%%~A"
    IF NOT DEFINED dstfname EXIT /B 1
)
CALL :install "%dstfname%" "%LOCALAPPDATA%\Programs\" bt "" || EXIT /B
(
    rem IF DEFINED installDest COMPACT /C /S:"%installDest%" /EXE:LZX
    IF EXIST "%LOCALAPPDATA%\Scripts\py\link_configs_to_Dropbox.py" START "" /B /WAIT py "%LOCALAPPDATA%\Scripts\py\link_configs_to_Dropbox.py" "%LocalAppData%\bt\config.ini" BrowserTamer
EXIT /B
)
:install <src> <destBase> <destName> <unpackedSubdirMask>
(
SET "src=%~1"
SET "destBase=%~2"
SET "destName=%~3"
SET "destFullName=%~2%~3"
SET "unpSubdirMask=%~4"
SET "unpTmp=%~2%~3.tmp"
)
(
    IF EXIST "%dstUnpName%" ECHO "%dstUnpName%" already exists
    RD /S /Q "%unpTmp%"
    %exe7z% x -xr!*.pdb -aos -y -o"%unpTmp%" -- "%src%" || EXIT /B
    SET "unpackedDir="
    IF EXIST "%dstUnpName%" (
        ECHO "%dstUnpName%" exists, removing
        IF EXIST "%dstUnpName%.bak" RD /S /Q "%dstUnpName%.bak"
        MOVE /Y "%dstUnpName%" "%dstUnpName%.bak"
    )
    IF NOT DEFINED unpSubdirMask (
        ECHO No subdir, renaming "%unpTmp%" to "%destBase%%~n1" directly
        MOVE "%unpTmp%" "%destBase%%~n1"
        ECHO N|RMDIR "%destFullName%"
        ECHO N|DEL "%destFullName%"
        MKLINK /J "%destFullName%" "%destBase%%~n1"
        SET "installDest=%destBase%%~n1"
        EXIT /B
    )
    FOR /D %%A IN ("%unpTmp%\%unpSubdirMask%") DO @(
        IF DEFINED unpackedDir (
            ECHO Found multiple directories matching "%unpSubdirMask%" in "%src%". Cannot proceed.
            EXIT /B
        )
        SET "unpackedDir=%%~A"
        SET "dstUnpName=%destBase%%%~nxA"
    )
)
(
    MOVE "%unpackedDir%" "%dstUnpName%"
    RD /S /Q "%unpTmp%"
    ECHO N|RMDIR "%destFullName%"
    ECHO N|DEL "%destFullName%"
    MKLINK /J "%destFullName%" "%dstUnpName%"
    SET "installDest=%dstUnpName%"
EXIT /B
)

:InitRemembering
@(
    SET "LatestFile="
    SET "LatestDate=0000000000:00"
EXIT /B
)
:RememberIfLatest
@(
    SET "current_file=%~2"
    SET "current_date=%~t2"
)
@(
    rem     01.12.2011 21:29
    IF "%current_date:~2,1%"=="." IF "%current_date:~5,1%"=="." SET "current_date=%current_date:~6,4%%current_date:~3,2%%current_date:~0,2%%current_date:~11%"
    rem     01.12.2011 21:29
    IF "%current_date:~2,1%"=="." IF "%current_date:~5,1%"=="." SET "current_date=%current_date:~6,4%%current_date:~3,2%%current_date:~0,2%%current_date:~11%"
)
@IF "%current_date%" GEQ "%LatestDate%" (
    SET "LatestFile=%current_file%"
    SET "LatestDate=%current_date%"
)
@(
    SET "%~1=%LatestFile%"
    EXIT /B
)
:IsOS64Bit
(
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" EXIT /B 0
    IF DEFINED PROCESSOR_ARCHITEW6432 EXIT /B 0
EXIT /B 1
)
