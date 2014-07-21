@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" https://www.torproject.org/download/download-easy.html.en *.exe -m -l 1 -HD www.torproject.org,dist.torproject.org "-A .exe,.asc,.en" -nd
