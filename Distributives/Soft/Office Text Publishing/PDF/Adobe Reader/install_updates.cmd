@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SETLOCAL
IF NOT DEFINED logmsi SET logmsi=%TEMP%\Adobe Reader Updates.log
IF DEFINED MSITransformFile SET MSITransformSwitch=/t"%MSITransformFile%"

FOR %%I IN ("%srcpath%updates\*.msp") DO msiexec.exe /update "%%~I" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"
FOR %%I IN ("%srcpath%updates\AdbeRdrSec*.msp") DO msiexec.exe /update "%%~I" %MSITransformSwitch% /qn /norestart /l+* "%logmsi%"

CALL "%~dp0RemoveUnneededAutorunAndServices.cmd"
ENDLOCAL
