@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar *.iso"
SET "moreDirs="
CALL wget_the_site.cmd www.acc.umu.se http://www.acc.umu.se/~bosse/
)
