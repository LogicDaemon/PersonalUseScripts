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
            CALL :VerAtLeast "%~1" "7.5"
            IF ERRORLEVEL 1 (
                CALL :DownloadArch %1 x86_64 x86-64
            ) ELSE (
                rem This changed with release 7.5.1, but still works for older releases
                CALL :DownloadArch %1 x86_64 x64 & POPD
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
:VerAtLeast <ver_to_compare> <required_ver>
(
SETLOCAL
FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%~1") DO (
    SET ver1sub1=%%I
    SET ver1sub2=%%J
    SET ver1sub3=%%K
    SET ver1sub4=%%L
)
FOR /F "delims=. tokens=1,2,3,4" %%I IN ("%~2") DO (
    SET ver2sub1=%%I
    SET ver2sub2=%%J
    SET ver2sub3=%%K
    SET ver2sub4=%%L
)
IF NOT DEFINED ver1sub2 SET ver1sub2=0
IF NOT DEFINED ver1sub3 SET ver1sub3=0
IF NOT DEFINED ver1sub4 SET ver1sub4=0
IF NOT DEFINED ver2sub2 SET ver2sub2=0
IF NOT DEFINED ver2sub3 SET ver2sub3=0
IF NOT DEFINED ver2sub4 SET ver2sub4=0
)
(
ENDLOCAL
rem No quotes to compare as numbers
IF %ver2sub1% GTR %ver1sub1% EXIT /B 1
IF %ver2sub2% GTR %ver1sub2% EXIT /B 1
IF %ver2sub3% GTR %ver1sub3% EXIT /B 1
IF %ver2sub4% GTR %ver1sub4% EXIT /B 1
EXIT /B 0
)
