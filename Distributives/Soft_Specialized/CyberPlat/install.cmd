@REM coding:OEM

SET InstallPath=d:\Program Files\PaymentModule

REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Payment Module_is1" /v "Inno Setup: App Path" /d "%InstallPath%"
CALL "%~dp0AddToNXExclusions.cmd"

REM After first run under admin, database becomes corrupt and does not work with user rights anymore

IF EXIST "%InstallPath%\CyberTerm.mdb" MOVE /Y "%InstallPath%\CyberTerm.mdb" "%InstallPath%\CyberTerm.mdb.beforeupdate%DATE%"
"%~dp0pmodule.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-
pskill CyberTerm.exe
IF EXIST "%InstallPath%\CyberTerm.mdb.beforeupdate%DATE%" MOVE /Y "%InstallPath%\CyberTerm.mdb.beforeupdate%DATE%" "%InstallPath%\CyberTerm.mdb"
