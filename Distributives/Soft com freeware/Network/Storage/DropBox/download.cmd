@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "logfname=dropbox.log"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://www.dropbox.com/download?plat=win" *.exe -N --no-check-certificate -A.exe
)
