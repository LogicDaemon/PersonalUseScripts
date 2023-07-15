@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://www2.aomeisoftware.com/download/adb/AOMEIBackupperStd.exe AOMEIBackupperStd.exe -N
    CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/adb/Backupper.exe Backupper.exe -N
    CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/adb/BackupperFull.exe BackupperFull.exe -N
    CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/adb/amlnx.iso amlnx.iso -N
)
