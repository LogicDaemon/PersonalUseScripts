@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
CALL "%baseScripts%\_DistDownload.cmd" http://www.clamav.net/win32/ClamAVWindowsSetup.exe
xln "%srcpath%temp\push@filetype=bootstrapper&affiliate=clamav" "%srcpath%ClamAVWindowsSetup.exe"
