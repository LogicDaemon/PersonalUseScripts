@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    SET "AddtoS_UScripts=0"

    CALL "%baseScripts%\_DistDownload.cmd" 32-bit-msi GoogleChromeStandaloneEnterprise.msi -Ni "%~dp0GoogleChromeStandaloneEnterprise.msi.url.txt"
    CALL "%baseScripts%\_DistDownload.cmd" 64-bit-msi GoogleChromeStandaloneEnterprise64.msi -Ni "%~dp0GoogleChromeStandaloneEnterprise64.msi.url.txt"
)
