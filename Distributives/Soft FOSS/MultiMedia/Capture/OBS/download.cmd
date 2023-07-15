@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    rem aria2c --allow-overwrite=true https://obsproject.com/downloads/torrents/OBS-Studio-28.1.2-Full-Installer-x64.exe.torrent
    rem curl https://cdn-fastly.obsproject.com/downloads/OBS-Studio-28.1.2-Full-Installer-x64.exe
    rem curl https://cdn-fastly.obsproject.com/downloads/OBS-Studio-28.1.2-Full-x64.zip
    SET distcleanup=1
    rem CALL "%baseScripts%\_DistDownload.cmd" https://obsproject.com/download OBS-Studio-*-Full-x64.zip -ml1 -nd -p -A.zip
    FOR /F "usebackq delims=" %%A IN (`CURL -s "https://obsproject.com/download" ^| grep -P -o "\/\/[^^"">]+?OBS-Studio-[\d\.]+-Full-(Installer-x64\.exe\.torrent|x64\.zip)"`) DO CALL :download "https:%%~A"
    EXIT /B
)
:download <url>
@(
    CALL "%baseScripts%\_DistDownload.cmd" %1 "*%~x1" -N
    IF "%~x1"==".torrent" IF EXIST "%~dp0%~nx1" (
        START "" /D "%srcpath%" /B aria2c --file-allocation=trunc --enable-dht6 --seed-time=0 --bt-detach-seed-only --bt-hash-check-seed=false --auto-file-renaming=false --check-integrity=true -T "%~dp0%~nx1"
    )
    EXIT /B
)
