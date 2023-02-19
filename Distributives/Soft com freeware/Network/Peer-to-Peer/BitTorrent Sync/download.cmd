@REM coding:OEM
SET srcpath=%~dp0
SET dstrename=BTSync.exe

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://download-lb.utorrent.com/endpoint/btsync/os/windows/track/stable stable

rem xln "%srcpath%temp\stable" "%srcpath%BTSync.exe"
rem before 16.09.2013: CALL \Scripts\_DistDownload.cmd http://btsync.s3-website-us-east-1.amazonaws.com/BTSync.exe
