@REM coding:OEM
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET distcleanup=1

IF NOT DEFINED baseScripts SET baseScripts=\Scripts
CALL "%baseScripts%\_GetWorkPaths.cmd"
rem srcpath with baseDistUpdateScripts replaced to baseDistributives
rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
rem logsDir - baseLogsDir with relpath (or nothing)
IF NOT DEFINED logsDir SET "logsDir=%workdir%"

CALL "%baseScripts%\_DistDownload.cmd" http://www.autohotkey.net/~Lexikos/AutoHotkey_L/AutoHotkey_L_Install.exe AutoHotkey_L_Install.exe
CALL "%baseScripts%\_DistDownload.cmd" http://www.autohotkey.net/~Lexikos/AutoHotkey_L/AutoHotkey_Lw.zip AutoHotkey_Lw.zip
CALL "%baseScripts%\_DistDownload.cmd" http://www.autohotkey.net/~Lexikos/AutoHotkey_L/AutoHotkey_L_Help.zip AutoHotkey_L_Help.zip
CALL "%baseScripts%\_DistDownload.cmd" http://www.autohotkey.net/~Lexikos/AutoHotkey_L/Ahk2Exe_L.zip Ahk2Exe_L.zip
