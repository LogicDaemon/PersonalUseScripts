@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar"
    SET "moreDirs="
    SET "wgetSideCMD=CALL wget_the_site.cmd"
)
(
%wgetSideCMD% eternallybored.org --trust-server-names -mnp -X"releases/old,src" https://eternallybored.org/misc/wget/
rem %wgetSideCMD% users.ugent.be http://users.ugent.be/~bpuype/wget/ http://users.ugent.be/~bpuype/wget/wget.exe
rem %wgetSideCMD% www.gnu.org http://www.gnu.org/software/wget/manual/wget.html
rem %wgetSideCMD% xoomer.virgilio.it http://xoomer.virgilio.it/hherold/
)
