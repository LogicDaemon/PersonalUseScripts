@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET distcleanup=1
)
(
    CALL "%baseScripts%\_DistDownload_sf.cmd" greenshot *.exe
    rem http://getgreenshot.org/current/
)
