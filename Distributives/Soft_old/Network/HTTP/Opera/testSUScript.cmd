@REM coding:OEM
SET http_proxy=http://192.168.1.1:3128/
CALL _get_SoftUpdateScripts_source.cmd
SET PATH=%PATH%;d:\Scripts
CALL download.cmd
PAUSE
