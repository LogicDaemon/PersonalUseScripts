@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
rem START /WAIT /B "rsync /v/Distributives u327016.your-storagebox.de:." 
rem Don't rsync, Unison reads the files back otherwise
rem CALL rsync.cmd --progress --stats --human-readable --8-bit-output --compress --compress-choice=zstd --fuzzy --times --hard-links --keep-dirlinks --links --safe-links --recursive --skip-compress=.7z,.rar,.xz,.gz,.cab,bz2,bzip2,png,jpg,mp4 --exclude-from=/v/Distributives/Local_Scripts/rsync-excludes.txt /v/Distributives u327016.your-storagebox.de:.
rem --update

	SET "hostname=AcerPH315-53-71HN"
	CALL "%~dp0unison_start_server.cmd"
)
@IF NOT DEFINED syncprog (
	SET "syncprog=%unisontext%"
) ELSE (
	IF NOT DEFINED filterSyncs IF "%unisontext%" NEQ "%syncprog%" SET "filterSyncs=1"
)
@(
	%unisontext% Distributives_autosync_paths@AcerPH315-53-71HN ^
		-root "%unisonServer%v:/Distributives" ^
		-prefer "%unisonServer%v:/Distributives" -auto -batch
	CALL "%~dp0unison_sync_check.cmd" "Distributives@u327016.your-storagebox.de" -root "%unisonServer%v:/Distributives"
	CALL "%~dp0unison_finish_syncs.cmd"
)
