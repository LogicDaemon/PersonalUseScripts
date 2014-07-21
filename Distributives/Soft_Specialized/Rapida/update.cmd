@REM coding:OEM
SET InstalledVersionFile=%TEMP%\Rapida-version.lastupdate.xml

FC "%~dp0version.xml" "%InstalledVersionFile%"
IF ERRORLEVEL 2 EXIT /B
IF NOT ERRORLEVEL 1 EXIT /B

SET SkipFlaggingAsInstalled=0

pskill.exe PaymMaster.exe
NET STOP PM_Service
START "" /D"d:\Program Files\Rapida\PaymMaster" /B /WAIT %comspec% /C KeyAccessInherit.cmd
PMSetup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /LOADINF="%~dp0pmsetup.inf"
IF ERRORLEVEL 1 SET SkipFlaggingAsInstalled=1
START "" /D"d:\Program Files\Rapida\PaymMaster" /B /WAIT %comspec% /C KeyAccessSYSTEMOnly.cmd

IF NOT "%SkipFlaggingAsInstalled%"=="1" COPY /Y "%~dp0version.xml" "%InstalledVersionFile%"
rem --- This is done in download.cmd --- COPY /Y version.xml version.prev.xml
