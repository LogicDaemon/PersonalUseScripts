@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.piriform.com/recuva/download/standard *.exe -m -l 1 -nd "-e robots=off" -H -Ddownload.piriform.com
