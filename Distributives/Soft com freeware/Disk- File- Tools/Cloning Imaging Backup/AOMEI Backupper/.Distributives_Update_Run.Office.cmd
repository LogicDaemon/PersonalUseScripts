@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/adb/Backupper.exe Backupper.exe -N
CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/adb/BackupperFull.exe BackupperFull.exe -N
