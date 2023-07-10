@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
    SETLOCAL ENABLEEXTENSIONS
    rem IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    rem IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"

    SET "ver=%~1"
    IF NOT DEFINED ver (ECHO Specify a version!&EXIT /B 1)
    PUSHD "%~dp032-bit" && (SET "srcpath=%~dp032-bit" & CALL :DownloadArch %1 x86 x86 & POPD)
    PUSHD "%~dp064-bit" && (
        SET "srcpath=%~dp064-bit" & (
            IF "%~1" LEQ "7.5." (
                rem This changed with release 7.5.1, but still works for older releases
                CALL :DownloadArch %1 x86_64 x64 & POPD
            ) ELSE (
                CALL :DownloadArch %1 x86_64 x86-64
            )
        )
        POPD
    )
    EXIT /B
)
:DownloadArch <ver> <dirArch> <nameArch>
@(
    IF NOT DEFINED workdir CALL "%baseScripts%\_GetWorkPaths.cmd"
    CALL :DownloadTorrent "LibreOffice_%~1_Win_%3.msi.torrent" "https://download.documentfoundation.org/libreoffice/stable/%~1/win/%2/LibreOffice_%~1_Win_%3.msi.torrent"
    FOR %%L IN ("en-GB" "en-US" "ru") DO @(
        CALL :DownloadTorrent "LibreOffice_%~1_Win_%3_helppack_%%~L.msi.torrent" "https://download.documentfoundation.org/libreoffice/stable/%~1/win/%2/LibreOffice_%~1_Win_%3_helppack_%%~L.msi.torrent"
        rem                                                                       https://download.documentfoundation.org/libreoffice/stable/7.5.4/win/x86_64/LibreOffice_7.5.4_Win_x86-64.msi.torrent
    )
)
(
    SET "TorrentsList="
    EXIT /B
)
:DownloadTorrent <name> <url>
@(
    ECHO Downloading %1 to %2
    CURL -RL -o %1 %2
    SET "TorrentsList=%TorrentsList% "
    rem --file-allocation=falloc requires Admin
    START "" /B aria2c --file-allocation=trunc --enable-dht6 --seed-time=0 --bt-detach-seed-only --bt-hash-check-seed=false --check-integrity=true -T %1
    EXIT /B
)
