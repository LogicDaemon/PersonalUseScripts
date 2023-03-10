@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

START "" /WAIT /B /D "%~dp0brooksman.net" wget -N http://brooksman.net/downloads/files/gdplugin_latest.zip >&0
