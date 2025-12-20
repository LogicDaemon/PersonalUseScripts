@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=%LOCALAPPDATA%\Scripts\software_update\Downloader"
)
(
rem     https://downloads.vivaldi.com/stable/Vivaldi.2.11.1811.52.x64.exe
rem     CALL "%baseScripts%\_DistDownload.cmd" https://update.vivaldi.com/update/1.0/public/appcast.x64.xml *.x64.exe -ml1 -A.exe -nd "-e robots=off" --user-agent="Mozilla/5.0 (Windows NT 5.4; Win64; x64; rv:10.0) Gecko/20100101 Firefox/10.0" -HD downloads.vivaldi.com,vivaldi.com
rem     SET "srcpath=%srcpath%32-bit\"
rem     CALL "%baseScripts%\_DistDownload.cmd" https://update.vivaldi.com/update/1.0/public/appcast.xml *.exe -ml1 -A.exe -nd "-e robots=off" -HD downloads.vivaldi.com,vivaldi.com
    PUSHD "%~dp0"
    FOR /F "usebackq delims=" %%A IN (`py "%baseScripts%\download_appcast.py" https://update.vivaldi.com/update/1.0/public/appcast.x64.xml`) DO SET "fname64=%%~A"
    POPD
    
    PUSHD "%~dp032-bit"
    FOR /F "usebackq delims=" %%A IN (`py "%baseScripts%\download_appcast.py" https://update.vivaldi.com/update/1.0/public/appcast.xml`) DO SET "fname32=%%~A"
    POPD
)
(
    ahk.exe "%baseScripts%\DistCleanup.ahk" "%~dp0%fname64%"
    ahk.exe "%baseScripts%\DistCleanup.ahk" "%~dp032-bit\%fname32%"
)
