@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://www.skype.com/go/getskype-msi *.msi -N

IF NOT DEFINED SUScripts EXIT /B
FOR %%I IN ("%~dp0*.msi") DO SET DistVer=%%~tI

SET DistVer=%DistVer: =_%
SET DistVer=%DistVer::=_%

SET CurrentLocation=%~p0
SET CurrentLocation=%%%%Distributives%%%%%CurrentLocation:\Distributives=%

CALL "%SUScripts%\..\templates\_add_withVer.cmd" %DistVer%
