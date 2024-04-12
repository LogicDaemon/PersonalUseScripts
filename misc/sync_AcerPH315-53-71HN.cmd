@(REM coding:CP866
"%LocalAppData%\Programs\msys64\usr\bin\rsync.exe" --progress --stats --human-readable --8-bit-output --compress --compress-choice=zstd --fuzzy --update --times --hard-links --keep-dirlinks --links --safe-links --recursive --skip-compress=.7z,.rar,.xz,.gz,.cab,bz2,bzip2,png,jpg,mp4 --exclude-from=/v/Distributives/Local_Scripts/rsync-excludes.txt /v/Distributives u327016.your-storagebox.de:.

SET "hostname=AcerPH315-53-71HN"
CALL _unison_get_command.cmd
SET "syncprog=%unisontext%"
SET "filterSyncs=0"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
