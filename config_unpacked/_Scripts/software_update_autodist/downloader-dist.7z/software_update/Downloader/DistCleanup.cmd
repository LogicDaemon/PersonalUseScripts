@(REM coding:CP866
REM Cleans up directory excluding the first argument.
REM If only argument is given, the whole directory except one file is cleaned up.
REM If two or more aruments, first is the mask, and others are exclusions.
REM 
REM by LogicDaemon <www.logicdaemon.ru>
REM WTFPL

SETLOCAL ENABLEEXTENSIONS
IF NOT DEFINED cleanup_action SET cleanup_action=ECHO 
IF NOT DEFINED cleanup_checkMoveCMD SET cleanup_checkMoveCMD="%temp%\cleanup_checkMove%RANDOM%.cmd"
SET excl=
SET exclN=0
IF "%~2"=="" (
    SET mask=%~dp1*%~x1
    SET excl=%~f1
    SET exclN=1
) ELSE (
    SET mask=%~1
    REM setting excl for case when there will be no %3
    SET excl=%~f2
    GOTO :cleanup_assembleExclusions
)

:cleanup_maincycle
    IF %exclN% GTR 1 GOTO :cleanup_multipleExclusions
    REM only exclusion
    FOR %%I IN ("%mask%") DO IF NOT "%%~fI"=="%excl%" %cleanup_action% "%%~I"
    ENDLOCAL
EXIT /B
:cleanup_multipleExclusions
    SET findmask=%mask:\=\\%
    FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find %mask%`) DO CALL %cleanup_checkMoveCMD% "%%~I"
    DEL %cleanup_checkMoveCMD%
    ENDLOCAL
EXIT /B

:cleanup_assembleExclusions
ECHO.>%cleanup_checkMoveCMD%
:cleanup_ae_cycle
    SHIFT
    IF "%~1"=="" GOTO :cleanup_assembleEnd
    ECHO IF "%%~1"=="%~1" EXIT /B 1>>%cleanup_checkMoveCMD%
    SET /A exclN+=1
GOTO :cleanup_ae_cycle
:cleanup_assembleEnd
    REM If only one exclusion, do not use %cleanup_checkMoveCMD%
    ECHO DEL "%%~1">>%cleanup_checkMoveCMD%
    IF %exclN%==1 DEL %cleanup_checkMoveCMD%
GOTO :cleanup_maincycle
