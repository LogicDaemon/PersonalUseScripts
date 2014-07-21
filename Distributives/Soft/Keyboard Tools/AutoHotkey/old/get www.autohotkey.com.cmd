@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET RARopts=-x*.exe -x*.zip -x*.chm
CALL wget_the_site.cmd www.autohotkey.com http://www.autohotkey.com/ -Xcommunity
