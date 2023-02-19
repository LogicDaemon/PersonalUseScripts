@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://dist.torproject.org/torbrowser/ torbrowser-install-*_ALL.exe -ml2 -nd -np -A.asc -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" https://dist.torproject.org/torbrowser/ torbrowser-install-win64-*_ALL.exe -ml2 -nd -np -A.asc -A.exe
)
