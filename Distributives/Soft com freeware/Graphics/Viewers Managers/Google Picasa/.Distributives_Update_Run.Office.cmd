@REM coding:OEM
SET srcpath=%~dp0
SET distcleanup=1
rem version 3.1.71.48 http://dl.google.com/picasa/picasa3-setup.exe

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://picasa.google.com/ *.exe -m -l 1 -nd -A.exe -e "robots=off" -H -D dl.google.com --user-agent="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US)"
