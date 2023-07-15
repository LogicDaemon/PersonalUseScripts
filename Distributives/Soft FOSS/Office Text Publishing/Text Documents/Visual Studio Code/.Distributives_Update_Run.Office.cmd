@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    CALL FindAutoHotkeyExe.cmd
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
    SET "distcleanup=1"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive" VSCode-win32-x64-*.zip
    FOR %%A IN (*.zip) DO @IF NOT EXIST "%%~dpnA.7z" IF NOT EXIST "%%~dpnA.LZMA2.7z" IF NOT EXIST "%%~dpnA.LZMA2BCJ2.7z" @(
        IF DEFINED AutohotkeyExe START "" /B "%AutohotkeyExe%" /ErrorStdOut download_server_for_latest_dist.ahk
        CALL repack_to_7z.cmd "%%~fA"
    )    
)
