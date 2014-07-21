@REM coding:OEM
SET srcpath=%~dp0
SET logfname=dropbox.log
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" "https://www.dropbox.com/download?plat=win" *.exe -N --no-check-certificate -A.exe
