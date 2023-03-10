@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Local_Scripts\software_update\Downloader"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" www.ltr-data.se/files/imdiskinst.exe imdiskinst.exe
    
    SET "srcpath=%~dp0reboot.pro ImDisk Toolkit\"
    rem CALL "%baseScripts%\_DistDownload_sf.cmd" imdisk-toolkit ImDiskTk-x64.zip
    CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/imdisk-toolkit/files/latest/download *.zip --user-agent="Wget/1.19.1 (mingw32)"
    CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.net/projects/imdisk-toolkit/files/latest/download *.zip --user-agent="Wget/1.19.1 (mingw64)"
)
