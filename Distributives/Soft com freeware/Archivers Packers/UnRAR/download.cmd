@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET RARopts=-x *.zip -x *.exe -x *.rar

c:\Common_Scripts\wget_the_site.cmd www.rarlab.com http://www.rarlab.com/rar_add.htm -ml1 -np "-A.zip,.exe,.rar"
