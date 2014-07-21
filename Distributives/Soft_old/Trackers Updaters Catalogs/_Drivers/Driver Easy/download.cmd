@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://cdn.drivereasy.com/drivereasy.com/DriverEasy_Setup.exe
