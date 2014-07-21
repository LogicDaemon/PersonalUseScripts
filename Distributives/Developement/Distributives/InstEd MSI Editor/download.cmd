@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

DEL "%srcpath%temp\download2.html"

rem .msi files are given by server without timestamp in header

CALL \Scripts\_DistDownload.cmd http://www.instedit.com/download2.html *.msi -ml 1 -nc -nd -HD apps.instedit.com
