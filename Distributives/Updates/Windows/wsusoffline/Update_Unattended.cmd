@REM coding:OEM
@ECHO OFF
sc config wuauserv start= auto
sc start wuauserv
PUSHD "%~dp0"
CALL cmd\DoUpdate.cmd /nobackup /updatercerts /updatecpp /instdotnet35 /instdotnet4 /updatetsc %*
POPD

rem /instielatest installs IE11, which isn't working with Megafon :(

rem /instofccnvs MSO converters, not needed usually
rem /updatedx shows messages, can't be installed unattendedly
rem /updatewmp :new WMP checks for windows XP license, and fails
rem /verify is very long
rem /instmssl is silverlight, DO NOT
