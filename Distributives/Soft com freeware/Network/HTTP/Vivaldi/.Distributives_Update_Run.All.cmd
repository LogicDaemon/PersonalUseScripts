@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
rem     https://downloads.vivaldi.com/stable/Vivaldi.2.11.1811.52.x64.exe
    CALL "%baseScripts%\_DistDownload.cmd" https://vivaldi.com *.x64.exe -ml1 -A.exe -nd "-e robots=off" --user-agent="Mozilla/5.0 (Windows NT 5.4; Win64; x64; rv:10.0) Gecko/20100101 Firefox/10.0" -HD downloads.vivaldi.com,vivaldi.com
    SET "srcpath=%srcpath%32-bit\"
    CALL "%baseScripts%\_DistDownload.cmd" https://vivaldi.com *.exe -ml1 -A.exe -nd "-e robots=off" -HD downloads.vivaldi.com,vivaldi.com
)
