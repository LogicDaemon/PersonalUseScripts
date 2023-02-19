@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    rem SET "logfname=download.log"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://crystalmark.info/redirect.php?product=CrystalDiskInfoInstaller" *.exe
    CALL "%baseScripts%\_DistDownload.cmd" "https://crystalmark.info/redirect.php?product=CrystalDiskInfo" *.zip
)
