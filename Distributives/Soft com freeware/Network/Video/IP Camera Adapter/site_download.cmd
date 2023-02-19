@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.msi *.7z"
SET "moreDirs="

REM HEAD method not allowed, thus --no-timestamping
)
CALL "%ProgramData%\mobilmir.ru\Common_Scripts\wget_the_site.cmd" ip-webcam.appspot.com -m --no-timestamping
