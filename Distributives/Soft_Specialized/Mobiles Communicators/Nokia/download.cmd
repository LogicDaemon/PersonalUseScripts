@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://nds1.nokia.com/files/support/global/phones/software/Nokia_Suite_webinstaller_ALL.exe *.exe -N --retry-connrefused
