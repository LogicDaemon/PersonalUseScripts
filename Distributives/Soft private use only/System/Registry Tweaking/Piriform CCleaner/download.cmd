@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET distcleanup=1
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://www.piriform.com/ccleaner/download/standard *.exe -m -l 1 -nd "-e robots=off" -H -Ddownload.piriform.com
)
