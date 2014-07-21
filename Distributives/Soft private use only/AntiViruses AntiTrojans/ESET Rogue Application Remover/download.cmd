@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
CALL \Scripts\_DistDownload.cmd http://download.eset.com/special/ERARemover_x86.exe ERARemover_x86.exe -N 
CALL \Scripts\_DistDownload.cmd http://download.eset.com/special/ERARemover_x64.exe ERARemover_x64.exe -N
