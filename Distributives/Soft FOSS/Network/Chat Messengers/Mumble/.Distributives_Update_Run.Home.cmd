@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    MKDIR "%~dp064-bit" 2>NUL
    MKDIR "%~dp032-bit" 2>NUL
    SET "distcleanup=1"
)
(
    SET "srcpath=%~dp032-bit\" & CALL "%baseScripts%\_DistDownload.cmd" "https://www.mumble.info/downloads/windows-32" mumble-*.msi -m -l 1 -H -nd
    SET "srcpath=%~dp064-bit\" & CALL "%baseScripts%\_DistDownload.cmd" "https://www.mumble.info/downloads/windows-64" mumble-*.winx64.msi -m -l 1 -H -nd
    EXIT /B
)
