@ECHO OFF

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET wgetcommonopt=-m -w 5 --random-wait --waitretry=300 -x -E -e robots=off -k -K -p -np

SET sitename=www.totalcmd.net
SET URL=http://%sitename%/

rem SET http_proxy=http://Srv-Inet:3128/
rem SET ftp_proxy=http://Srv-Inet:3128/
rem -c		### contunue downloading files
rem -a wget.log	### write all output to that log
rem -t 64	### 64 retries
rem -N		### use timestamping
rem -R <url>	### do not download

START "Unpacking site..." /b /wait /D"%srcpath%" rar x -u -r sites.rar

START "Downloading %sitename%" /b /wait /D"%srcpath%" wget %wgetcommonopt% %URL%
REM -rH

START "Packing %sitename%" /b /wait /D"%srcpath%" rar m -as -m5 -r -x@pack_exclude.lst -- sites.rar *.*
