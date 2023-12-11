@(REM coding:CP866
CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
NET USE \\AcerPH315-53-71HN
SET "hostname=ADerbenev-L-SPB"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
