@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    
    CURL -s https://api.github.com/repos/FAForever/downlords-faf-client/releases | jq ".[] | select(.name | contains(\"alpha\") | not) | .assets[].browser_download_url | select(contains(\".tar.gz\") | not)" >downloads.tmp
    FOR /F "usebackq delims=" %%A IN (downloads.tmp) DO @(
        ECHO Downloading "%%~A"
        CURL -sz "%%~nxA" -RJOL "%%~A" && (
            IF "%%~xA"==".exe" SET "downloadedexe=1"
            IF "%%~xA"==".zip" SET "downloadedzip=1"
            IF DEFINED downloadedexe IF DEFINED downloadedzip EXIT /B
        )
    )
rem      | .browser_download_url
    EXIT /B
)
