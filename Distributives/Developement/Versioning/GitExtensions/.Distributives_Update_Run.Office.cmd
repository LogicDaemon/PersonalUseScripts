@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    
    PUSHD "%~dp0"
    FOR /F "usebackq delims=" %%A IN (`CURL https://api.github.com/repos/gitextensions/gitextensions/releases/latest ^| jq ".assets.[].browser_download_url"`) DO @(
        SET "name=%%~nxA"
        CALL :CheckName && CURL -z "%%~nxA" -RJOL "%%~A"
    )
    POPD
    EXIT /B
)
:CheckName
(
    IF "%name:~-4%"==".zip" IF NOT "%name:~0,23%"=="GitExtensions-Portable-" EXIT /B 1
    EXIT /B 0
)
