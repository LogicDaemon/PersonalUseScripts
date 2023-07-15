@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload_sf.cmd" qbittorrent *.exe
    SET "dstrename=*.exe"
    CALL "%baseScripts%\_DistDownload_sf.cmd" qbittorrent *.exe*
)
