@REM coding:OEM

SCHTASKS /Create /TN Rapida_Update /SC ONSTART /TR "%~dp0update.cmd"
SCHTASKS /Change /TN Rapida_Update /SC ONSTART /TR "%~dp0update.cmd"
