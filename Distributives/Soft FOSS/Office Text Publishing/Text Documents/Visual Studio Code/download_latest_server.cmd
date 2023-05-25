@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
    SET "distcleanup=1"

    rem https://stackoverflow.com/a/57601121
)
(
    IF NOT EXIST "%~dp0server" MKDIR "%~dp0server"
    SET "srcpath=%srcpath%server\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://update.code.visualstudio.com/latest/server-linux-x64/stable" *.gz
)
