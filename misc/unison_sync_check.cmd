@REM coding:CP1
:CheckSync
@IF NOT DEFINED name SET "name=%~nx1"
@(
	IF DEFINED filterSyncs (
		<NUL %unisontext% %* "-auto=false"
	) ELSE (
		VERIFY INVALID 2>NUL
	)
	IF ERRORLEVEL 1 SET "sync_%name%=%*"
	IF DEFINED FinishSyncAfterCheck (
		START "%name%" %comspec% /C "%~dp0unison_finish_syncs.cmd"
		SET "sync_%name%="
	)
	SET name=
	EXIT /B
)
