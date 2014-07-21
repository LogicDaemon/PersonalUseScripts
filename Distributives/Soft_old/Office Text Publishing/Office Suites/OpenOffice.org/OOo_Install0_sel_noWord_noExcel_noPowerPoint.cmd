@REM coding:OEM
@ECHO OFF

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET SetSystemSettings=0

"%srcpath%OOo_Install_commonproc.cmd"
