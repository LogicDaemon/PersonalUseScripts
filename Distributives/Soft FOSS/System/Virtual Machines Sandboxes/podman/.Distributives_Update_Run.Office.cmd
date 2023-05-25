@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
CALL "%baseScripts%\_GetWorkPaths.cmd"
(
    IF NOT EXIST "%workdir%" MKDIR "%workdir%"
    CURL https://api.github.com/repos/containers/podman/releases | jq ".[] | select(.prerelease==false) | select(.draft==false) | .assets | .[].browser_download_url" > "%workdir%release_urls.txt" || EXIT /B
    FOR /F "usebackq delims=" %%A IN ("%workdir%release_urls.txt") DO (
        SET "urlbase=%%~pA"
        SET "fname=%%~nxA"
        CALL :CheckDownload "%%~A"
    )
    EXIT /B
)
:CheckDownload <url>
(
    CALL :getfname dver "%urlbase:~0,-1%"
)
IF EXIST "%srcpath%%dver%\%fname%" (
    SET "timecond=-z "%srcpath%%dver%\%fname%""
) ELSE (
    SET "timecond="
)
(
    IF "%shasums%"=="shasums" GOTO :CheckDownloadMatch
    IF "%~x1"==".exe" GOTO :CheckDownloadMatch
    IF "%~x1"==".msi" GOTO :CheckDownloadMatch
    IF "%fname:~-18%"=="-windows_amd64.zip" GOTO :CheckDownloadMatch
    EXIT /B
    :CheckDownloadMatch
    START "" /B /WAIT /D "%workdir%" CURL %timecond% -RJOL %1
    IF EXIST "%workdir%%fname%" MOVE /Y "%workdir%%fname%" "%srcpath%%dver%\"
    EXIT /B
)
:getfname
(
    SET "%~1=%~nx2"
    EXIT /B
)
rem with
rem CALL "%baseScripts%\_DistDownload.cmd" %1 "%fname%"
rem wget fails to download from github with the following error:
rem 
rem Failed to Fopen file C:\Users\aderbenev\AppData\Local\Programs\bin/.wget-hsts
rem ERROR: could not open HSTS store at 'C:\Users\aderbenev\AppData\Local\Programs\bin/.wget-hsts'. HSTS will be disabled.
rem --2023-05-25 15:32:35--  https://github.com/containers/podman/releases/download/v4.5.0/podman-4.5.0-setup.exe
rem Resolving github.com (github.com)... 192.30.255.112
rem Connecting to github.com (github.com)|192.30.255.112|:443... connected.
rem HTTP request sent, awaiting response... 302 Found
rem Location: https://objects.githubusercontent.com/github-production-release-asset-2e65be/109145553/ebc0ae7c-b52a-40fe-be5c-3a88bc057916?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230525%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230525T123237Z&X-Amz-Expires=300&X-Amz-Signature=99c5b226a661d66c38a3b4211cce607c1c42b8fed514674b400e18cc65a994cb&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=109145553&response-content-disposition=attachment%3B%20filename%3Dpodman-4.5.0-setup.exe&response-content-type=application%2Foctet-stream [following]
rem The destination name is too long (462), reducing to 241
rem --2023-05-25 15:32:37--  https://objects.githubusercontent.com/github-production-release-asset-2e65be/109145553/ebc0ae7c-b52a-40fe-be5c-3a88bc057916?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230525%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230525T123237Z&X-Amz-Expires=300&X-Amz-Signature=99c5b226a661d66c38a3b4211cce607c1c42b8fed514674b400e18cc65a994cb&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=109145553&response-content-disposition=attachment%3B%20filename%3Dpodman-4.5.0-setup.exe&response-content-type=application%2Foctet-stream
rem Resolving objects.githubusercontent.com (objects.githubusercontent.com)... 185.199.110.133, 185.199.111.133, 185.199.108.133, ...
rem Connecting to objects.githubusercontent.com (objects.githubusercontent.com)|185.199.110.133|:443... connected.
rem HTTP request sent, awaiting response... 200 OK
rem Length: 40615264 (39M) [application/octet-stream]
rem ebc0ae7c-b52a-40fe-be5c-3a88bc057916@X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230525%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230525T123237Z&X-Amz-Expires=300&X-Amz-Signature=99c5b226a661d66c38a3b4211cce: No such file or directory
rem 
rem Cannot write to 'ebc0ae7c-b52a-40fe-be5c-3a88bc057916@X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20230525%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230525T123237Z&X-Amz-Expires=300&X-Amz-Signature=99c5b226a661d66c38a3b4211cce' (Bad file descriptor).
