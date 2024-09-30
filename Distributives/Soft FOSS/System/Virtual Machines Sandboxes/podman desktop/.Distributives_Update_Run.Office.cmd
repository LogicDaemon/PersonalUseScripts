@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
CALL "%baseScripts%\_GetWorkPaths.cmd"
(
    IF NOT EXIST "%workdir%" MKDIR "%workdir%"
    CURL https://api.github.com/repos/containers/podman-desktop/releases/latest | jq ".assets | .[].browser_download_url" > "%workdir%release_urls.txt" || EXIT /B
    FOR /F "usebackq delims=" %%A IN ("%workdir%release_urls.txt") DO (
        SET "urlbase=%%~pA"
        SET "fname=%%~nxA"
        CALL :CheckDownload "%%~A"
    )
    IF NOT DEFINED dver EXIT /B
)
@(
    IF NOT EXIST "%srcpath%%dver%\." EXIT /B
    FOR /D %%A IN ("%srcpath%v*.*") DO IF /I "%%~nxA" NEQ "%dver%" ahk.exe "%baseScripts%\mvold.ahk" "%%~A"
    EXIT /B
)
:CheckDownload <url>
IF NOT DEFINED dver (
    CALL :getfname dver "%urlbase:~0,-1%"
)
(
    rem Don't need ARM64 variants
    rem podman-desktop-1.6.4-setup-arm64.exe podman-desktop-1.6.4-setup-arm64.exe podman-desktop-airgap-1.6.4-arm64.exe
    IF "%fname:~-10%"=="-arm64.exe" EXIT /B 1
    IF NOT DEFINED CREATED_VER_DIR (
        IF NOT EXIST "%srcpath%%dver%" MKDIR "%srcpath%%dver%"
        SET CREATED_VER_DIR=1
    )
    IF "%~nx1"=="shasums" GOTO :CheckDownloadMatch
    IF "%~x1"==".exe" GOTO :CheckDownloadMatch
    IF "%~x1"==".msi" GOTO :CheckDownloadMatch
    rem https://github.com/containers/podman/releases/download/v4.8.0/podman-remote-release-windows_amd64.zip
    IF "%fname:~-18%"=="-windows_amd64.zip" GOTO :CheckDownloadMatch
    EXIT /B 1
)
:CheckDownloadMatch
IF EXIST "%srcpath%%dver%\%fname%" (
    SET "timecond=-z "%srcpath%%dver%\%fname%""
) ELSE (
    SET "timecond="
)
(
    START "" /B /WAIT /D "%workdir%" CURL %timecond% -RJOL %1
    IF EXIST "%workdir%%fname%" MOVE /Y "%workdir%%fname%" "%srcpath%%dver%\%fname%"
    EXIT /B
)
:getfname
(
    SET "%~1=%~nx2"
    EXIT /B
)
