@REM coding:OEM
SET srcpath=%~dp0

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://files.avast.com/iavs5x/setup_av_free.exe
CALL "%baseScripts%\_DistDownload.cmd" http://files.avast.com/iavs5x/vpsupd.exe

SET srcpath=%~dp0UnInstaller\
CALL "%baseScripts%\_DistDownload.cmd" http://files.avast.com/files/eng/aswclear.exe
CALL "%baseScripts%\_DistDownload.cmd" http://files.avast.com/files/eng/avastclear.exe

REM http://www.avast.com/download-update
