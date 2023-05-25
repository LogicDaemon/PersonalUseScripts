@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"

    SET "srcpath=%~dp0v1\"
    CALL ahk.cmd "%~dp0v1\download.ahk"
    SET "srcpath=%~dp0v2\"
    CALL "%~dp0v2\download_latest.cmd"
    EXIT /B
)
