@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://www.hwinfo.com/download.php hw32_*.zip -ml1 -A.zip -Xbeta
    CALL "%baseScripts%\_DistDownload.cmd" http://www.hwinfo.com/download.php hw64_*.zip -ml1 -A.zip -Xbeta
)
