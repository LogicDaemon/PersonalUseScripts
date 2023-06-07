@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS

    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    START "" /B /D"%srcpath%" wget -ml1 https://7-zip.org/download.html -A.exe,.msi,.7z
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7zr.exe
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*-x64.exe -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*.exe -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*-x64.msi -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*.msi -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*-extra.7z -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html 7z*-src.7z -ml1
rem     CALL "%baseScripts%\_DistDownload.cmd" https://7-zip.org/download.html lzma*.7z -ml1
EXIT /B
)
rem https://7-zip.org/a/7z2201-x64.exe
rem https://7-zip.org/a/7z2201.exe
rem https://7-zip.org/a/7z2201-arm64.exe
rem https://7-zip.org/a/7z2201-x64.msi
rem https://7-zip.org/a/7z2201.msi
rem https://7-zip.org/a/7z2201-extra.7z
rem https://7-zip.org/a/7z2201-src.7z
rem https://7-zip.org/a/lzma2201.7z
rem https://7-zip.org/a/7zr.exe
