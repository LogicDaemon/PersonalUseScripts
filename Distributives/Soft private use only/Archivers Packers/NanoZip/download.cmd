@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET RARopts=-x *.zip

c:\Common_Scripts\wget_the_site.cmd www.nanozip.net http://www.nanozip.net/download.html
