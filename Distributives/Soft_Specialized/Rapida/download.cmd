@REM coding:OEM
COPY /Y "%~dp0version.xml" "%~dp0version.prev.xml"

START "" /B /WAIT /D"%~dp0" wget -N http://soft.rapida.ru/download/pmsetup/version.xml
FC "%~dp0version.xml" "%~dp0version.prev.xml"
IF NOT ERRORLEVEL 1 EXIT /B

START "" /B /WAIT /D"%~dp0" wget -N http://soft.rapida.ru/download/pmsetup/PMSetup.exe

rem initial variant
rem START "" /B /WAIT /D"%~dp0" wget -rxN http://soft.rapida.ru/download/pmsetup/pm_download.php
