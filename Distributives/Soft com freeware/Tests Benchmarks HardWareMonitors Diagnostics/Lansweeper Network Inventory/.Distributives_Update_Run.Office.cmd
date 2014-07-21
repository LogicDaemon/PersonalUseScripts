@REM coding:OEM
SET srcpath=%~dp0

rem http://www.lansweeper.com/Download.aspx Lansweeper.exe -m -l 1 -H -D download.lansweeper.com -nd -A "Lansweeper.exe,aspx"
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://www.lansweeper.com/getfile.aspx LansweeperSetup.exe -m -l 1 -H -D download.lansweeper.com -nd -A ".exe,.aspx"
