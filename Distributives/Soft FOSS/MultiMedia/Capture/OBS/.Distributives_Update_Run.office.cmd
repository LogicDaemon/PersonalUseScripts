@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    IF "%~d0"=="\\" (
        SET "VENVPATH=%TEMP%\OBS-downloader.venv"
    ) ELSE (
        SET "VENVPATH=%~dp0.venv""
    )
)
(
    rem aria2c --allow-overwrite=true https://obsproject.com/downloads/torrents/OBS-Studio-28.1.2-Full-Installer-x64.exe.torrent
    rem curl https://cdn-fastly.obsproject.com/downloads/OBS-Studio-28.1.2-Full-Installer-x64.exe
    rem curl https://cdn-fastly.obsproject.com/downloads/OBS-Studio-28.1.2-Full-x64.zip
    SET distcleanup=1
    rem CALL "%baseScripts%\_DistDownload.cmd" https://obsproject.com/download OBS-Studio-*-Full-x64.zip -ml1 -nd -p -A.zip
    rem FOR /F "usebackq delims=" %%A IN (`CURL -s "https://obsproject.com/download" ^| grep -P -o "\/\/[^^"">]+?OBS-Studio-[\d\.]+-Full-(Installer-x64\.exe\.torrent|x64\.zip)"`) DO CALL :download "https:%%~A"
    IF NOT EXIST "%VENVPATH%" (
        CALL py.cmd -m venv "%VENVPATH%" || py -m venv "%VENVPATH%"
        CALL "%VENVPATH%\Scripts\activate"
        pip install -r "%~dp0requirements.txt"
    )
    CALL "%VENVPATH%\Scripts\activate"
    python "%~dp0download_from_main_page.py"
    EXIT /B
)
:download <url>
@(
    CALL "%baseScripts%\_DistDownload.cmd" %1 "*%~x1" -N
    IF "%~x1"==".torrent" IF EXIST "%~dp0%~nx1" START "" /WAIT /B /D "%srcpath%" aria2c --file-allocation=trunc --enable-dht6 --seed-time=0 --bt-detach-seed-only --bt-hash-check-seed=false --auto-file-renaming=false --check-integrity=true -T "%~dp0%~nx1"
    EXIT /B
)
