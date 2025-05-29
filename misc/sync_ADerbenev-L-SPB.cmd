@(REM coding:CP866
PING -n 1 AcerPH315-53-71HN || (PAUSE & EXIT)
CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
NET USE \\AcerPH315-53-71HN
SET "hostname=ADerbenev-L-SPB"
rem SET "unisonPort=10355"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
