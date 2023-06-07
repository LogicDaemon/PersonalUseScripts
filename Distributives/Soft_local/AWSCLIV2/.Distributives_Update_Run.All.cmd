@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "srcpath=%~dp0"
    CALL "%baseScripts%\_DistDownload.cmd" https://awscli.amazonaws.com/AWSCLIV2.msi
EXIT /B
)
