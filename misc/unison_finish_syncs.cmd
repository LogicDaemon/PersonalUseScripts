@(REM coding:CP866
	IF NOT DEFINED syncprog ECHO syncprog undefined!
	FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO (
		START "" /B /WAIT %syncprog% %%B %unisonopt%
		SET "%%~A="
	)
	IF NOT DEFINED SkipServerStop IF DEFINED unisonServer (
		ECHO Stopping the unison server...
		REM lock files remain if started too soon
		PING 127.0.0.1 -n 5 >NUL
		%unisontext% "%TEMP%" "%unisonServer%%TEMP:\=/%" -testserver -killserver
		SET unisonServer=
	)
EXIT /B
)
