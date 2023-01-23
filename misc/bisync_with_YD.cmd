@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
SET "src=%~1"
CALL :SetDestTrimSrc %1 || EXIT /B
)
:appendnextarg
@(
    SET "rcloneargs=%rcloneargs% %2"
    IF NOT "%~3"=="" (
        SHIFT /2
        GOTO :appendnextarg
    )
)
(
@CHCP 65001
rclone bisync "%src%" "%dest%" --timeout 60m -v %rcloneargs%
@START "" /B /LOW COMPACT /C /EXE:LZX "%LocalAppData%\rclone\bisync\*.*"
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
    SET "dest=YD:%~nx1"
    EXIT /B 0
)
:showerror
@(
ECHO Error code %ERRORLEVEL%
PAUSE
EXIT /B
)
