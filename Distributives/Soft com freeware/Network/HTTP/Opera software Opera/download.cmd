@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

START "" /B /WAIT /D "%srcpath%" wget -ml 2 http://www.opera.com/download/get/?partner=www&opsys=Windows
