@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/keepass/files/latest/download "*.exe@viasf=1" -N -A "exe@viasf=1"
    FOR %%A IN ("%~dp0*.exe@viasf=1") DO REN "%%~A" *.exe
    FOR %%A IN ("%~dp0*.zip@viasf=1") DO REN "%%~A" *.zip
)
