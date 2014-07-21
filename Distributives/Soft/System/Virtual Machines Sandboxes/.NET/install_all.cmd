@REM coding:OEM
@ECHO OFF
sc config wuauserv start= auto
sc start wuauserv
PUSHD "%~dp0..\..\..\..\Updates\Windows\wsusoffline" || EXIT /B
CALL cmd\DoUpdate /nobackup /instdotnet35 /instdotnet4 %*
CALL cmd\DoUpdate /nobackup /instdotnet35 /instdotnet4 %*
POPD

rem /updatedx shows messages, can't be installed unattendedly
rem /updatewmp :new WMP checks for windows XP license, and fails
rem /verify is very long
rem /instmssl is silverlight, DO NOT
