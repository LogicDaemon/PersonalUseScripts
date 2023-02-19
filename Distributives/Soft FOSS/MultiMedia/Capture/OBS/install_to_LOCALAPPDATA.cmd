@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL find7zexe.cmd
    
    CALL :InitRemembering
    FOR %%A IN ("%~dp0OBS-Studio-*-Full-x64.zip") DO CALL :RememberIfLatest dstfname "%%~A"
    IF NOT DEFINED dstfname EXIT /B 1
)
@(
    CALL :install "%dstfname%"
    FOR /D %%A IN ("%~dp0plugins\*") DO CALL :installplugin "%%~A"
EXIT /B
)
:install
@(
    %exe7z% x -aos -y -o"%LOCALAPPDATA%\Programs\%~n1" -- "%~1" || EXIT /B
    ECHO N|RMDIR "%LOCALAPPDATA%\Programs\obs-studio"
    ECHO N|DEL "%LOCALAPPDATA%\Programs\obs-studio"
    MKLINK /D "%LOCALAPPDATA%\Programs\obs-studio" "%LOCALAPPDATA%\Programs\%~n1" || MKLINK /J "%LOCALAPPDATA%\Programs\obs-studio" "%LOCALAPPDATA%\Programs\%~n1"
    SET "installDest=%LOCALAPPDATA%\Programs\%~n1"
EXIT /B
)
:installplugin
@(
    SET "dstfname="
    CALL :InitRemembering
    FOR %%A IN ("%~1\*-win64.zip") DO CALL :RememberIfLatest dstfname "%%~A"
    IF NOT DEFINED dstfname EXIT /B 1
)
@(
    %exe7z% x -aos -y -o"%installDest%" -- "%dstfname%"
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
