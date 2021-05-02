@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
rem     CALL "%baseScripts%\_DistDownload.cmd" https://rufus.akeo.ie/ *.exe -ml1 -A.exe
    CALL FindAutohotkeyExe.cmd "%~dp0download_latest.ahk"
)
