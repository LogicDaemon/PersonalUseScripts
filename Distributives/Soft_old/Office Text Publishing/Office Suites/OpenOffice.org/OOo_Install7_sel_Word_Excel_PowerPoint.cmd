@REM coding:OEM
@ECHO OFF

SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET SetSystemSettings=1
SET SELECT_WORD=1
SET SELECT_EXCEL=1
SET SELECT_POWERPOINT=1

"%srcpath%OOo_Install_commonproc.cmd"
