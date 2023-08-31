@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

SET "srcpath=%~dp0"
SET "workdir=%~dp0temp"
)
@(
SET "noarchmasks=*.exe *.zip"
SET "wgetextendedoptions= "
SET "wgetwaitoptions= "
CALL wget_the_site.cmd www.nyam.pe.kr https://www.nyam.pe.kr/dev/imagine
ln -r "%workdir%\www.nyam.pe.kr" "%srcpath%www.nyam.pe.kr"
)
