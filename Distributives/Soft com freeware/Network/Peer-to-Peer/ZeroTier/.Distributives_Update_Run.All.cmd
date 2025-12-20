@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"

    IF NOT DEFINED baseScripts SET "baseScripts=%LOCALAPPDATA%\Scripts\software_update\Downloader"
    PUSHD "%~dp0"
    CALL "%~dp0winget_download.cmd"
)
