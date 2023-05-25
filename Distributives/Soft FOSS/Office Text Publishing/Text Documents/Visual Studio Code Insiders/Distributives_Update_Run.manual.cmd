@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    CALL FindAutoHotkeyExe.cmd
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://code.visualstudio.com/sha/download?build=insider&os=win32-x64-archive" VSCode-win32-x64-*.zip

    IF DEFINED AutohotkeyExe START "" /B "%AutohotkeyExe%" /ErrorStdOut download_server_for_latest_dist.ahk
)
