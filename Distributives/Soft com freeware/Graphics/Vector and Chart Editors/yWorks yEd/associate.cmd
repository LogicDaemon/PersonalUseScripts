@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

ASSOC .graphml=yWorks.yEd.graphml
FTYPE yWorks.yEd.graphml=javaw.exe -jar "%~dp0yed.jar" "%%1"
