@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

rem CALL \Scripts\_DistDownload.cmd http://java.com/ru/download/manual_v6.jsp jre-6*-windows-i586.exe -m -l 1 -H -D "sdlc-esd.sun.com,javadl.sun.com" -nd -e "robots=off" --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)"
CALL \Scripts\_DistDownload.cmd "http://javadl.sun.com/webapps/download/AutoDL?BundleId=68291" jre-6*-windows-i586.exe -N -O jre-6-windows-i586.exe
