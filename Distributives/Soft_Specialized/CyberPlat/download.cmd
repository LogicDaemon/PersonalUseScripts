@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://payment.cyberplat.ru/distr/pmodule/pmodule.exe pmodule.exe
CALL "%baseScripts%\_DistDownload.cmd" http://payment.cyberplat.ru/distr/pmodule/6.0/ru/pm6setup_ru.zip pm6setup_ru.zip
