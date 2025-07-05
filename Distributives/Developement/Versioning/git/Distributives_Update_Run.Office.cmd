@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq delims=" %%A IN (`CURL https://gitforwindows.org/latest-tag.txt`) DO (
        SET "tag=%%~A"
        CURL https://api.github.com/repos/git-for-windows/git/releases | jq ".[] | select(.tag_name==\"%%~A\") | .assets" > "%~dp0latest_assets.json"
        GOTO :found
    )
EXIT /B
:found
(
    IF NOT EXIST "%~dp0%tag%" MKDIR "%~dp0%tag%"
    PUSHD "%~dp0%tag%"
    FOR /F "usebackq delims=" %%A IN (`jq ".[].browser_download_url" "%~dp0latest_assets.json"`) DO @(
        SET "name=%%~nxA"
        CALL :CheckName && CURL -z "%%~nxA" -RJOL "%%~A"
    )
    POPD
    EXIT /B
)
:CheckName
(
    IF "%name:~-6%"==".nupkg" EXIT /B 1
    IF "%name:~-8%"==".tar.bz2" EXIT /B 1
    IF "%name:~-10%"=="-arm64.exe" EXIT /B 1
    IF "%name:~-10%"=="-arm64.zip" EXIT /B 1
    IF "%name:~-13%"=="-arm64.7z.exe" EXIT /B 1
    IF "%name:~0,5%"=="pdbs-" EXIT /B 1
    IF "%name:~23%"=="mingw-w64-i686-git-pdb-" EXIT /B 1
    IF "%name:~34%"=="mingw-w64-i686-git-test-artifacts-" EXIT /B 1
    IF "%name:~25%"=="mingw-w64-x86_64-git-pdb-" EXIT /B 1
    IF "%name:~36%"=="mingw-w64-x86_64-git-test-artifacts-" EXIT /B 1
    IF "%name:~32%"=="mingw-w64-clang-aarch64-git-pdb-" EXIT /B 1
    IF "%name:~43%"=="mingw-w64-clang-aarch64-git-test-artifacts-" EXIT /B 1
    EXIT /B 0
)
