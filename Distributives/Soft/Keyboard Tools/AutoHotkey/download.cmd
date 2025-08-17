@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
@(
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp\ if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
    IF NOT DEFINED workdir SET "workdir=%srcpath%temp\"
)
@(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    START "" /B py "%baseScripts%\_DistDownload.py" https://autohotkey.com/download/ahk-install.exe AutoHotkey_1.*.exe
    START "" /B py "%baseScripts%\_DistDownload.py" https://autohotkey.com/download/ahk.zip AutoHotkey_1.*.zip
    
    SET "srcpath=%~dp0v2\"
    START "" /B py "%baseScripts%\_DistDownload.py" https://www.autohotkey.com/download/ahk-v2.exe *.exe
    START "" /B py "%baseScripts%\_DistDownload.py" https://www.autohotkey.com/download/ahk-v2.zip *.zip
)
