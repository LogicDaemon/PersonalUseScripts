@REM coding:OEM
SET srcpath=%~dp0
IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_DistDownload.cmd" http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/amd64/msert.exe msert.exe -N
