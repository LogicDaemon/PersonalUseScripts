@REM coding:OEM

IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

CALL \Scripts\_DistDownload.cmd http://mse.dlservice.microsoft.com/download/7/6/0/760B9188-4468-4FAD-909E-4D16FE49AF47/ruRU/x86/mseinstall.exe

rem http://www.microsoft.com/security/portal/definitions/adl.aspx
START "" /D"%srcpath%" /B /WAIT wget -N "http://go.microsoft.com/fwlink/?LinkID=121721&arch=x86"
