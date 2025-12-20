@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
    SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=%LOCALAPPDATA%\Scripts\software_update\Downloader"
)
@(
    CALL "%baseScripts%\_DistDownload.cmd" https://aka.ms/vs/17/release/vc_redist.arm64.exe VC_redist.arm64.exe
    CALL "%baseScripts%\_DistDownload.cmd" https://aka.ms/vs/17/release/vc_redist.x86.exe VC_redist.x86.exe
    CALL "%baseScripts%\_DistDownload.cmd" https://aka.ms/vs/17/release/vc_redist.x64.exe VC_redist.x64.exe
EXIT /B
)
