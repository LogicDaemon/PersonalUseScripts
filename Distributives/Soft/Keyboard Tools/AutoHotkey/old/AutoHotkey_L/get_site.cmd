@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET RARopts=-x*.exe -x*.zip -x*.chm -xversion.txt -xwww.autohotkey.net\www.autohotkey.net
CALL wget_the_site www.autohotkey.net http://www.autohotkey.net/~Lexikos/AutoHotkey_L/ -Xwww.autohotkey.net
