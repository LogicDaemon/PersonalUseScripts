@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive" VSCode-win32-x64-*.zip
    FOR %%A IN (*.zip) DO @IF NOT EXIST "%%~dpnA.7z" IF NOT EXIST "%%~dpnA.LZMA2.7z" IF NOT EXIST "%%~dpnA.LZMA2BCJ2.7z" CALL repack_to_7z.cmd "%%~fA"
)
