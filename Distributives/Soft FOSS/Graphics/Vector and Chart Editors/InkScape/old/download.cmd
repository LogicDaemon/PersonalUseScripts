@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
CALL "%baseScripts%\_DistDownload_sf.cmd" inkscape inkscape-*-win32.7z
