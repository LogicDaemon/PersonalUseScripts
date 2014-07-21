@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

regjump.ahk HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
