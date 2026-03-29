@(REM coding:CP866
rem START "%%~A" -i -color true
FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO START "" /B /WAIT "%LocalAppData%\Programs\scoop\apps\git\current\usr\bin\mintty.exe" -t "%%~A" -e %comspec:\=\\% \/C %syncprog% %%B %unisonopt% -sortnewfirst
REM monochrome
rem FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO %syncprog% %%B %unisonopt% -sortnewfirst
IF NOT DEFINED unisonServer (
	ECHO unisonServer variable is not defined.
	ECHO This script is intended to be called after unison_start_server.cmd, which sets up the unisonServer variable.
	EXIT /B 1
) >&2
ECHO Stopping the unison server...
REM lock files remain if started too soon
PING 127.0.0.1 -n 5 >NUL
%unisontext% "%TEMP%" "%unisonServer%%TEMP:\=/%" -testserver -killserver
)
