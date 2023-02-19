@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://downloads.rclone.org/rclone-current-windows-amd64.zip *-amd64.zip
    CALL "%baseScripts%\_DistDownload.cmd" https://downloads.rclone.org/rclone-current-windows-386.zip *-386.zip
)
