@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
	rem PING -n 1 AcerPH315-53-71HN || (PAUSE & EXIT)
	rem CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
	rem NET USE \\AcerPH315-53-71HN
	SET "hostname=LenLegPro7-16IRX8H-82WQ00SUS"
	CALL "%~dp0unison_start_server.cmd" %*
)
(
IF NOT DEFINED syncprog (
	SET "syncprog=%unisontext%"
) ELSE (
	IF NOT DEFINED filterSyncs IF NOT [%unisontext%]==[%syncprog%] SET "filterSyncs=1"
)
(
	%unisontext% "Distributives_autosync_paths@AcerPH315-53-71HN" ^
		-root "%unisonServer%d:/Distributives" ^
		-prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch

	CALL :CheckSync "%unisonServer%%USERPROFILE:\=/%\.unison" ^
		"\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" ^
		-ignore "Name *" -ignorenot "Name *.prf" -ignorenot "Name default"
	CALL :CheckSync "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"
	FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO CALL :CheckSync "%%~nA" "-auto=false"
	FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO %syncprog% %%B %unisonopt%
	EXIT /B
)
CALL "%~dp0unison_stop_server.cmd"
EXIT /B
)
:CheckSync
IF NOT DEFINED name SET "name=%~nx1"
(
	IF DEFINED filterSyncs (
		<NUL %unisontext% %* "-auto=false" || SET "sync_%name%=%*"
	) ELSE (
		VERIFY INVALID 2>NUL
	) || SET "sync_%name%=%*"
	SET name=
	EXIT /B
)
