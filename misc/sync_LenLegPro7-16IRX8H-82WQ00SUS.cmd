@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
	rem PING -n 1 AcerPH315-53-71HN || (PAUSE & EXIT)
	rem CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
	rem NET USE \\AcerPH315-53-71HN
	SET "hostname=LenLegPro7-16IRX8H-82WQ00SUS"
	CALL "%~dp0unison_start_server.cmd"
)
@IF NOT DEFINED syncprog (
	SET "syncprog=%unisontext%"
) ELSE (
	IF NOT DEFINED filterSyncs IF NOT [%unisontext%]==[%syncprog%] SET "filterSyncs=1"
)
@(
	%unisontext% "Distributives_autosync_paths@AcerPH315-53-71HN" ^
		-root "%unisonServer%d:/Distributives" ^
		-prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch

	CALL "%~dp0unison_sync_check.cmd" "%unisonServer%%USERPROFILE:\=/%\.unison" ^
		"\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" ^
		-ignore "Name *" -ignorenot "Name *.prf" -ignorenot "Name default"
	CALL "%~dp0unison_sync_check.cmd" "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"
	FOR %%A IN ("%USERPROFILE%\.unison\*_to_AcerPH315-53-71HN.prf") DO CALL "%~dp0unison_sync_check.cmd" "%%~nA" "-auto=false"
	CALL "%~dp0unison_finish_syncs.cmd"
)
