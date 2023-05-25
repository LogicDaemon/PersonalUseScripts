@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"

    SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar"
    SET "moreDirs="
)
(
    CALL "%baseScripts%\_DistDownload.cmd" ftp://ftp.cpuid.com/hwmonitor/ hwmonitor_* -m -np
    REM www.cpuid.com http://www.cpuid.com/softwares/hwmonitor.html
)
