@REM coding:OEM
SET srcpath=%~dp0
rem not working CALL "%baseScripts%\_DistDownload.cmd" http://sourceforge.jp/projects/crystaldiskinfo/releases/ *.zip -ml2 -A.zip -H
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://crystalmark.info/download/index-e.html *.exe -ml1 -HD release.crystaldew.info
CALL "%baseScripts%\_DistDownload.cmd" http://crystalmark.info/download/index-e.html *.zip -ml1 -HD release.crystaldew.info
