@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

regjump.ahk HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
