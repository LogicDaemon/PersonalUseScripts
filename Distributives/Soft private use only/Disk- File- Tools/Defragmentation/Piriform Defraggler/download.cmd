@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET distcleanup=1
IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
CALL "%baseScripts%\_DistDownload.cmd" http://www.piriform.com/defraggler/download/standard *.exe -ml 1 -nd "-e robots=off" -H -Ddownload.piriform.com
