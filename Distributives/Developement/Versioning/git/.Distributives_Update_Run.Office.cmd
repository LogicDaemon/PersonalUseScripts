@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq delims=" %%A IN (`CURL https://gitforwindows.org/latest-tag.txt`) DO (
        CURL https://api.github.com/repos/git-for-windows/git/releases | jq ".[] | select(.tag_name==\"%%~A\") | .assets" > "%~dp0latest_assets.json"
        GOTO :found
    )
EXIT /B
:found
    FOR /F "usebackq delims=" %%A IN (`jq ".[].browser_download_url" "%~dp0latest_assets.json"`) DO CURL -z "%%~nxA" -RJOL "%%~A"
)
