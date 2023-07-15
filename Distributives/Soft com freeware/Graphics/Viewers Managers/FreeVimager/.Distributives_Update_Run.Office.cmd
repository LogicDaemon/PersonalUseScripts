@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    SET "distcleanup=1"
    SET "AddtoS_UScripts=0"
    rem FreeVImager is Donationware since ver 9.0.
    CALL "%baseScripts%\_DistDownload.cmd" http://www.contaware.com/downloads/latest/russian/ FreeVimager-*-Portable-Rus.exe -ml1 -nd -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://www.contaware.com/downloads/latest/russian/ FreeVimager-*-Setup-Rus.exe -ml1 -nd -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://www.contaware.com/downloads/latest/english/ FreeVimager-*-Portable.exe -ml1 -nd -A.exe
    CALL "%baseScripts%\_DistDownload.cmd" http://www.contaware.com/downloads/latest/english/ FreeVimager-*-Setup.exe -ml1 -nd -A.exe
)
