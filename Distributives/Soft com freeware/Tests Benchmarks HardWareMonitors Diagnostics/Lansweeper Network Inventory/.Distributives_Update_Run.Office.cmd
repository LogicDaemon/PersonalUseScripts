@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://www.lansweeper.com/getfile.aspx LansweeperSetup.exe -m -l 1 -H -D download.lansweeper.com -nd -A ".exe,.aspx"
)
