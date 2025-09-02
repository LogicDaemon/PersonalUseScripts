@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
    SET "AddtoS_UScripts=0"
    SET "distcleanup=1"
    
    CALL FindAutoHotkeyExe.cmd
)
(
    rem Content-Disposition: attachment; filename=VSCode-win32-x64-1.100.0-insider.zip; filename*=UTF-8''VSCode-win32-x64-1.100.0-insider.zip
    FOR /F "usebackq delims=: tokens=2" %%A IN (`CURL -LI --styled-output "https://code.visualstudio.com/sha/download?build=insider&os=win32-x64-archive" ^| FINDSTR /BR "Content-Disposition: "`) DO CALL :ParseContentDisposition "%%~A"
)
(
    CALL "%baseScripts%\_DistDownload.cmd" "https://code.visualstudio.com/sha/download?build=insider&os=win32-x64-archive" VSCode-win32-x64-*.zip
    
    IF DEFINED AutohotkeyExe (
        START "" /D "%~dp0" /B "%AutohotkeyExe%" /ErrorStdOut "%~dp0cleanup.ahk"    
        rem START "" /D "%~dp0" /B "%AutohotkeyExe%" /ErrorStdOut "download_server_for_latest_dist.ahk"
    )

    EXIT /B
)
:ParseContentDisposition
(
    rem  attachment; filename=VSCode-win32-x64-1.100.0-insider.zip; filename*=UTF-8''VSCode-win32-x64-1.100.0-insider.zip
    FOR /F "delims=; tokens=1,2,3" %%A IN ("%~1") DO (
        rem attachment;
        SET "nameToCheck=%%~A"
        CALL :ParseNameToken && EXIT /B
        
        rem filename=VSCode-win32-x64-1.100.0-insider.zip;
        SET "nameToCheck=%%~B"
        CALL :ParseNameToken && EXIT /B
        
        rem filename*=UTF-8''VSCode-win32-x64-1.100.0-insider.zip
        SET "nameToCheck=%%~C"
        CALL :ParseNameToken && EXIT /B
    )
    EXIT /B 1
)
:ParseNameToken
(
    rem filename=VSCode-win32-x64-1.100.0-insider.zip
    FOR /F "tokens=1* delims==" %%A IN ("%nameToCheck%") DO (
        IF "%%~A"==" filename" (SET "dstrename=%%~B" && EXIT /B)
        IF "%%~A"=="filename" (SET "dstrename=%%~B" && EXIT /B)
    )
EXIT /B 1
)    
