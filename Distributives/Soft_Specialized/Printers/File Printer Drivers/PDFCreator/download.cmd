@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
SET logfname=PDFCreator_setup.log
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" "http://download.pdfforge.org/download/pdfcreator/PDFCreator-stable?download" PDFCreator-*_setup.exe
