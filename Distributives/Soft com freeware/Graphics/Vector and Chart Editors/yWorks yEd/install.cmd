@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET destpath=%ProgramFiles%\yWorks\yEd

7z x -o"%destpath%" -- yEd-*.zip

ASSOC .graphml=yWorks.yEd.graphml
FTYPE yWorks.yEd.graphml=javaw.exe -jar "%destpath%\yed.jar" "%%1"
