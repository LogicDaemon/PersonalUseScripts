@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem rclone_to_YD.cmd rclonecommand src dest    args
rem 0                1             2   3       4
    SET rclonecommand=%1
    SET "src=%~2"
    SET "dest=%~3"
    CALL :SetDestTrimSrc %2 || EXIT /B
)
:appendnextarg
@(
    SET "rcloneargs=%rcloneargs% %4"
    IF NOT "%~5"=="" (
        SHIFT /4
        GOTO :appendnextarg
    )
)
(
@CHCP 65001
rclone %rclonecommand% "%src%" "YD:%dest%" --timeout 60m %rcloneargs%
@IF ERRORLEVEL 1 GOTO :showerror
@EXIT /B
)
:SetDestTrimSrc <src>
@(
    IF "%~nx1"=="" (
        IF "%src:~-1%"=="\" (
            SET "src=%src:~0,-1%"
            CALL :SetDestTrimSrc "%src:~0,-1%"
            EXIT /B
        )
        EXIT /B 1
    )
    IF NOT DEFINED dest CALL :SetWithReplacedBackslashes dest "%~p1"
EXIT /B 0
)
:SetWithReplacedBackslashes
@(
    SETLOCAL
    SET "v=%~2"
)
@(
    ENDLOCAL
    SET "%~1=%v:\=/%"
EXIT /B
)
:showerror
@(
    ECHO Error code %ERRORLEVEL%
    PAUSE
EXIT /B
)
