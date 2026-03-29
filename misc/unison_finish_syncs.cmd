@(REM coding:CP866
FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO START "" /B /WAIT %syncprog% %%B %unisonopt%
IF NOT DEFINED unisonServer (
	ECHO unisonServer variable is not defined.
	ECHO This script is intended to be called after unison_start_server.cmd, which sets up the unisonServer variable.
	EXIT /B 1
)
	ECHO Stopping the unison server...
	REM lock files remain if started too soon
	PING 127.0.0.1 -n 5 >NUL
	%unisontext% "%TEMP%" "%unisonServer%%TEMP:\=/%" -testserver -killserver
EXIT /B
)
