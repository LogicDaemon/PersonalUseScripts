@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET RARopts=-x*.zip -x*.rar
CALL wget_the_site.cmd www.acc.umu.se http://www.acc.umu.se/~bosse/
