@(REM coding:CP866
SET "hostname=AcerPH315-53-71HN"
CALL _unison_get_command.cmd
SET "syncprog=%unisontext%"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
