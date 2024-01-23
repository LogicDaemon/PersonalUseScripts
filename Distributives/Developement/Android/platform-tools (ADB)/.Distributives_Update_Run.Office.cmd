@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    rem SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://dl.google.com/android/repository/platform-tools-latest-windows.zip *.zip
)
