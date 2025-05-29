@(REM coding:CP866
rem PING -n 1 AcerPH315-53-71HN || (PAUSE & EXIT)
rem CALL "%SecretDataDir%\connect_AcerPH315-53-71HN.cmd"
rem NET USE \\AcerPH315-53-71HN
SET "hostname=LenLegPro7-16IRX8H-82WQ00SUS"
CALL "%~dp0sync_with_unison_server.cmd" %*
)
