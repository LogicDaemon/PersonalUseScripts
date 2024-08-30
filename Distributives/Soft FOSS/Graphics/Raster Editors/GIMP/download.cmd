@(REM coding:CP866
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    CALL "%baseScripts%\_GetWorkPaths.cmd"
    rem srcpath with baseDistUpdateScripts replaced to baseDistributives
    rem relpath is srcpath relatively to baseDistributives (no trailing backslash)
    rem workdir - baseWorkdir with relpath (or %srcpath%temp if baseWorkdir isn't defined)
    rem logsDir - baseLogsDir with relpath (or nothing)
)
@IF NOT DEFINED workdir SET "workdir=%srcpath%\temp"
@(
    IF NOT DEFINED logsDir SET "logsDir=%workdir%"
    IF NOT EXIST "%srcpath%old\." MKDIR "%srcpath%old"
    MOVE "%srcpath%*.torrent" "%srcpath%old\"
    CALL "%baseScripts%\_DistDownload.cmd" https://www.gimp.org/downloads/ *.torrent -A.exe.torrent -rl1 -nd -HDdownload.gimp.org
    FOR %%A IN ("%srcpath%*.torrent") DO aria2c --file-allocation=trunc --enable-dht6 --seed-time=0 --bt-detach-seed-only --bt-hash-check-seed=false --check-integrity=true -T "%%~A"
)
