@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    SET "UseTimeAsVersion=1"
    CALL "%baseScripts%\_DistDownload.cmd" http://intelloware.com/Download/ru-RU/QuickConfig.msi QuickConfig.msi
    SET "AddtoS_UScripts=0"
    CALL "%baseScripts%\_DistDownload.cmd" http://intelloware.com/Download/QuickConfig.zip QuickConfig.zip
)
