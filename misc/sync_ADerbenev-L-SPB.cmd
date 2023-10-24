@(REM coding:CP866
NET USE \\AcerPH315-53-71HN
SET "hostname=ADerbenev-L-SPB"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
