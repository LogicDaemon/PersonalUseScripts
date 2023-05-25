@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
    SET "UseTimeAsVersion=1"
)
(
    FOR %%A IN (ru en-US en-GB) DO @(
        SET "UpdateScriptName=Mozilla FireFox"
        IF NOT EXIST "%~dp0%%A 64-bit\." MKDIR "%~dp0%%A 64-bit"
        SET "srcpath=%~dp0%%A 64-bit\"
        CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=%%A" "Firefox Setup *.exe"

        SET "addToS_UScripts=0"
        IF NOT EXIST "%~dp0%%A 32-bit\." MKDIR "%~dp0%%A 32-bit"
        SET "srcpath=%~dp0%%A 32-bit\"
        CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-latest&os=win&lang=%%A" "Firefox Setup *.exe"
    )
    
    SET "UpdateScriptName=Mozilla FireFox Beta"
    IF NOT EXIST "%~dp0en-US 64-bit beta\." MKDIR "%~dp0en-US 64-bit beta"
    SET "srcpath=%~dp0en-US 64-bit beta\"
    CALL "%baseScripts%\_DistDownload.cmd" "https://download.mozilla.org/?product=firefox-beta-latest-ssl&os=win64&lang=en-US" "Firefox Setup *.exe"
)
