@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
	PING -n 1 AcerPH315-53-71HN || (PAUSE & EXIT)
	CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
	NET USE \\AcerPH315-53-71HN
	SET "hostname=ADerbenev-L-SPB"
	CALL "%~dp0unison_start_server.cmd" %*
)
IF NOT DEFINED syncprog (
	SET "syncprog=%unisontext%"
) ELSE (
	IF NOT DEFINED filterSyncs IF [%unisontext%] NEQ [%syncprog%] SET "filterSyncs=1"
)
(
	%unisontext% Distributives_autosync_paths@AcerPH315-53-71HN ^
		-root "%unisonServer%d:/Distributives" ^
		-prefer "\\AcerPH315-53-71HN\Distributives$" -auto -batch
	SET name=UnisonDefault & CALL "%~dp0sync_check.cmd" "%unisonServer%%USERPROFILE:\=/%/My SecuriSync/config/.unison/default" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison/default"
	CALL "%~dp0sync_check.cmd" "%unisonServer%%USERPROFILE:\=/%/My SecuriSync/config/.unison" "\\AcerPH315-53-71HN\Users\LogicDaemon\.unison" -ignore "Regex [^.]+" -ignore "Name .nomedia" -ignore "Name unison.log"
	CALL "%~dp0sync_check.cmd" "%unisonServer%d:/Users/LogicDaemon/.continue" "\\AcerPH315-53-71HN\Users\LogicDaemon\Dropbox\config\#Home\.continue"
	CALL "%~dp0sync_check.cmd" "Distributives@AcerPH315-53-71HN" -root "%unisonServer%d:/Distributives"
	SET name=ahkLib & CALL "%~dp0sync_check.cmd" "%USERPROFILE%\Documents\AutoHotkey\Lib" "\\AcerPH315-53-71HN\Users\LogicDaemon\Dropbox\Projects\AutoHotkey\Lib"
	CALL "%~dp0sync_check.cmd" "aderbenev_Scripts@AcerPH315-53-71HN" -root "%unisonServer%%LOCALAPPDATA:\=/%\Scripts"
	FOR /F "usebackq delims== tokens=1*" %%A IN (`SET sync_`) DO %syncprog% %%B %unisonopt%
	CALL "%~dp0unison_stop_server.cmd"
EXIT /B
)
