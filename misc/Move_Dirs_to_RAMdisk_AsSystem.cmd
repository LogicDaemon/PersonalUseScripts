@(REM coding:CP866
IF NOT EXIST d:\Users\LogicDaemon EXIT /B 1
SET USERPROFILE=d:\Users\LogicDaemon
SET APPDATA=d:\Users\LogicDaemon\AppData\Roaming
SET LOCALAPPDATA=d:\Users\LogicDaemon\AppData\Local
CALL "%~dp0Move Dirs to RAMdisk.cmd"
) >"R:\%~n0.log" 2>&1
COMPACT /C /EXE:LZX "R:\%~n0.log"
