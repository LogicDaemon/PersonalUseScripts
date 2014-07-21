@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.hwinfo.com/download.php hw32_*.zip -ml1 -A.zip -Xbeta
CALL "%baseScripts%\_DistDownload.cmd" http://www.hwinfo.com/download.php hw64_*.zip -ml1 -A.zip -Xbeta

