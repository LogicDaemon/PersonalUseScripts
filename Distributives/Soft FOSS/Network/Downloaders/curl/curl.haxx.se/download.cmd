@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" https://curl.haxx.se/windows/ curl-*-win64-mingw.zip -ml1 -nd -A.zip
    CALL "%baseScripts%\_DistDownload.cmd" https://curl.haxx.se/windows/ curl-*-win32-mingw.zip -ml1 -nd -A.zip
)
