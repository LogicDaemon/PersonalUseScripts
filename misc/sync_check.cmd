@REM coding:CP866
:CheckSync
@IF NOT DEFINED name SET "name=%~nx1"
@(
	IF DEFINED filterSyncs (
		<NUL %unisontext% %* "-auto=false" || SET "sync_%name%=%*"
	) ELSE (
		VERIFY INVALID 2>NUL
	) || SET "sync_%name%=%*"
	SET name=
	EXIT /B
)
