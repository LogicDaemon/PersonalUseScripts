@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET "dstBase=%LocalAppData%\Programs\putty"
    CALL find7zexe.cmd x -y -aoa -o"%TEMP%\putty.dist.tmp" -- "%~dp0putty.zip"
    CALL :GetFileVer ver "%TEMP%\putty.dist.tmp\PUTTY.EXE" || EXIT /B
)
SET "dstVerDir=%dstBase%-%ver%"
@(
    IF EXIST "%dstVerDir%" GOTO :cleanup
    MOVE "%TEMP%\putty.dist.tmp" "%dstVerDir%"
    RD "%dstBase%" 2>NUL
    MKLINK /D "%dstBase%" "%dstVerDir%" || MKLINK /J "%dstBase%" "%dstVerDir%" || EXIT /B
)
:cleanup
@(
    RD /S /Q "%TEMP%\putty.dist.tmp"
    EXIT /B
)

:GetFileVer <varname> <path>
@(
    SETLOCAL
    SET "fileNameForWMIC=%~2"
)
@SET "fileNameForWMIC=%fileNameForWMIC:\=\\%"
(
    FOR /F "usebackq skip=1" %%I IN (`wmic datafile where Name^="%fileNameForWMIC%" get Version`) DO @(
        REM IF NOT "%%~I"=="" does not work here, it's always unequal, but it looks like there's \n or something nasty is in the loop var
        REM it works after assigning to the env var though
        SET "verWMIC=%%~I"
        CALL :GetFileVerCheckEmpty tmp_ver && GOTO :GetFileVer_done
    )
)
:GetFileVer_done
@(
    ENDLOCAL
    IF "%tmp_ver%"=="" EXIT /B 1
    SET "%~1=%tmp_ver%"
    EXIT /B
)

:GetFileVerCheckEmpty
@(
    ENDLOCAL
    IF NOT "%verWMIC%"=="" (
        SET "%~1=%verWMIC%"
        EXIT /B 0
    )
    EXIT /B 1
)
