@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET baseScripts=\Scripts
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
)
@IF NOT DEFINED workdir SET "workdir=%srcpath%\temp"
@(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    
    SET "noarchmasks=*.exe *.zip *.gz *.bz2 *.rar *.msi *.7z *.cab *.jpg *.bat *.cmd *.ps1"
    SET "moreDirs="
    PUSHD "%workdir%" || EXIT /B
    CALL wget_the_site.cmd schinagl.priv.at https://schinagl.priv.at/nt/hardlinkshellext/hardlinkshellext.html "-Xabout,schinagl.priv.at,nt/hardlinkshellext/beta,nt/ln/beta" -R.JPG -R.png -R.gif
    POPD
    ln -r "%workdir%\schinagl.priv.at" .
)
