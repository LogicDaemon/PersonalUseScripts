@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

    SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
)
(
    rem https://openhardwaremonitor.org/files/openhardwaremonitor-v0.9.5.zip
    CALL "%baseScripts%\_DistDownload.cmd" https://openhardwaremonitor.org/downloads/ *.zip -A.zip -ml1 -nd "-Xfeed,comments,wp-json,wordpress,support,screenshots,documentation,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025"
)
