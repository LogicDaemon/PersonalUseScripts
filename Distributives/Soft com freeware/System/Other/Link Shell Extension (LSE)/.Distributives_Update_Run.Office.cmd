@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar *.msi *.7z *.cab *.jpg *.bat *.cmd *.ps1"
SET "moreDirs="
)
CALL "wget_the_site.cmd" schinagl.priv.at https://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html "-Xabout,schinagl.priv.at,nt/hardlinkshellext/beta,nt/ln/beta" -R.JPG
