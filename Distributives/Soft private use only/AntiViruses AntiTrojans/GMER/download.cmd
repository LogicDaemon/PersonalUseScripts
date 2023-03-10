@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

CALL \Scripts\_DistDownload.cmd http://www2.gmer.net/gmer.zip gmer.zip
