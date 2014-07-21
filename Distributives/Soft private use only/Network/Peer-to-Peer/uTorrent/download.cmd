@REM coding:OEM
SET srcpath=%~dp0

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://download-new.utorrent.com/endpoint/utorrent/os/windows/track/stable/uTorrent.exe *.exe

rem CALL \Scripts\_DistDownload.cmd http://download.utorrent.com/2.2.1/utorrent.exe *.exe
rem CALL \Scripts\_DistDownload.cmd http://download.utorrent.com/3.0/utorrent.exe *.exe
rem CALL \Scripts\_DistDownload.cmd http://download.utorrent.com/beta/utorrent-latest.exe *.exe
