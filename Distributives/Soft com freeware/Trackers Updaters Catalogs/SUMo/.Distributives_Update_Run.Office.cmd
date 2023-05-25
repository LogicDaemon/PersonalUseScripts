@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://www.kcsoftwares.com/files/sumo.7z sumo.7z -N
)
