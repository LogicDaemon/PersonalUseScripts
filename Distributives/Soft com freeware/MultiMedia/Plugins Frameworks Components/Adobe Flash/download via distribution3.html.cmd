@(REM coding:CP866
REM Automated software update scripts
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    CALL "%~dp0getfilenames.cmd"
    IF NOT DEFINED runDir SET "runDir=%~dp0temp"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
)
(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"

    CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%PluginFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
    CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%ActiveXFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
    CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%ppapiFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate

    CALL :GetLargestNumber LatestPluginFilename "%runDir%\%PluginFilename%"
    CALL :GetLargestNumber LatestActiveXFilename "%runDir%\%ActiveXFilename%"
    CALL :GetLargestNumber LatestppapiFilename "%runDir%\%ppapiFilename%"
)
(
    rem second run with latest filenames for linking
    IF DEFINED LatestPluginFilename CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestPluginFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
    IF DEFINED LatestActiveXFilename CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestActiveXFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate
    IF DEFINED LatestppapiFilename CALL "%baseScripts%\_DistDownload.cmd" https://www.adobe.com/products/flashplayer/distribution3.html "%LatestppapiFilename%" -ml 1 -A.exe -HD download.macromedia.com -nd "-e robots=off" --no-check-certificate

    IF NOT DEFINED s_uscripts EXIT /B

    CALL "%s_uscripts%\..\templates\_add_withVer.cmd" "%~dp0%LatestPluginFilename%"
    rem CALL "%s_uscripts%\..\templates\_add_withVer.cmd" "%~dp0%ActiveXFilename%"
EXIT /B
)
:GetLargestNumber
(
    FOR /F "usebackq delims=" %%I IN (`DIR /B /O-N %2`) DO (
	SET "%~1=%%~I"
	EXIT /B
    )
EXIT /B 1
)
