@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
    CALL find7zexe.cmd
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF DEFINED OS64Bit (
        SET "distFName=rclone-*-windows-amd64.zip"
        SET "cleanupMask=rclone-v*-windows-amd64"
    ) ELSE (
        SET "distFName=rclone-*-windows-386.zip"
        SET "cleanupMask=rclone-v*-windows-386"
    )
    SET "tempUnpackDir=%TEMP%\rclone-dist-temp"
    SET "destBaseDir=%LOCALAPPDATA%\Programs"
)
(
    SET "linkName=%destBaseDir%\rclone"
    CALL :InitRemembering
    FOR %%A IN ("%~dp0%distFName%") DO CALL :RememberIfLatest distpath "%%~A"
    IF NOT DEFINED distpath EXIT /B 1
)
(
    %exe7z% x -y -aoa -o"%tempUnpackDir%" -- "%distpath%"
    FOR /D %%B IN ("%tempUnpackDir%\*.*") DO IF NOT EXIST "%destBaseDir%\%%~nxB" (
        SET "unpackedDir=%%~nxB"
        MOVE "%%~B" "%destBaseDir%\%%~nxB" || EXIT /B 1
        ECHO N|RD "%linkName%"
        MKLINK /J "%linkName%" "%destBaseDir%\%%~nxB" && GOTO :cleanup
    )
    EXIT /B 1
)
:cleanup
    RD /S /Q "%tempUnpackDir%"
    FOR /D %%A IN ("%destBaseDir%\%cleanupMask%") DO IF "%%~nxA" NEQ "%unpackedDir%" DEL "%%~A\rclone.exe" && RD /S /Q "%%~A"
EXIT /B

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
