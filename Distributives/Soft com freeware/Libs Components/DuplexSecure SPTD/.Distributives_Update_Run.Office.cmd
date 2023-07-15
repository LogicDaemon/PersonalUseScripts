@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.duplexsecure.com/downloads *-x64.exe
CALL "%baseScripts%\_DistDownload.cmd" http://www.duplexsecure.com/downloads *-x86.exe
