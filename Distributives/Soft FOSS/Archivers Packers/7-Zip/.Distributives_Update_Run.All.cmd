@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS

    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/sevenzip/files/latest/download "*.7z" -N -A "7z"
EXIT /B
)
