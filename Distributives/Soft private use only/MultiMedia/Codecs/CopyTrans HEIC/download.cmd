@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://www.copytrans.net/download-zip?program=CTH" *.exe
)
