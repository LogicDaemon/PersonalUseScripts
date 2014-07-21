@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

rem START "" /D"%~dp0" /B /WAIT wget --no-check-certificate -N "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B13A2A729-85D7-542F-5B41-12FF59EE03A3%7D%26lang%3Dru%26browser%3D3%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26installdataindex%3Ddefaultbrowser/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" 32-bit-msi *.msi --no-check-certificate -Ni "%~dp0GoogleChromeStandaloneEnterprise.msi.url.txt"
CALL "%baseScripts%\_DistDownload.cmd" 64-bit-msi *.msi --no-check-certificate -Ni "%~dp0GoogleChromeStandaloneEnterprise64.msi.url.txt"
