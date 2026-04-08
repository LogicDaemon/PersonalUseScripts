@(REM coding:CP866
IF NOT EXIST d:\Users\LogicDaemon EXIT /B 1
SET USERPROFILE=d:\Users\LogicDaemon
SET APPDATA=d:\Users\LogicDaemon\AppData\Roaming
SET LOCALAPPDATA=d:\Users\LogicDaemon\AppData\Local
"%LOCALAPPDATA%\Programs\bin\UpdateRamdiskLinks.exe" "%~dp0ramdisk-config.yaml"
COMPACT /C /F /EXE:LZX "R:\*.log"
)
