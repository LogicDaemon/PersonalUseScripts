@REM coding:OEM
SET srcpath=%~dp0

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://www.hirensbootcd.org/download/ *.zip -ml 1 -A.zip -nd -HD mirrors.nlab.su
CALL "%baseScripts%\_DistDownload.cmd" http://www.hirensbootcd.org/download/ *.iso -ml 1 -A.iso -nd -HD mirrors.nlab.su
