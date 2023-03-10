@REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

c:\SysUtils\wget.exe -ml2 -np -Xcomponents/tag -e robots=off --no-check-certificate http://www.foobar2000.org/getcomponent/ http://www.foobar2000.org/components
rem -H -D foobar2000.org 
