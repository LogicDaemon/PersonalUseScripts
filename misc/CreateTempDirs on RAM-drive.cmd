@(
REM coding:CP866
ECHO OFF
)
:WaitForR
IF NOT EXIST R:\ (
    PING -n 2 127.0.0.1 >NUL
    GOTO :WaitForR
)
(
MKDIR R:\Temp
@CALL "%~dp0Move Dirs to RAMdisk.cmd" %* >"R:\Move Dirs to RAMdisk.log" 2>&1
)
