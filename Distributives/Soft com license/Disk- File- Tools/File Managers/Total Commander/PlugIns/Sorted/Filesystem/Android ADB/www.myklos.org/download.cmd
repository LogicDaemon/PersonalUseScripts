@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

START "" /B /WAIT /D "%srcpath%" wget -N http://www.myklos.org/download/adbplugin.zip
