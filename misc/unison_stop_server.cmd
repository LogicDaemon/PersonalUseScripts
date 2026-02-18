@(REM coding:CP866
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

