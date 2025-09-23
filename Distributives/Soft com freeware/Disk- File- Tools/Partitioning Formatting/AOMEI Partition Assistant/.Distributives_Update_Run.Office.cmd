@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
    IF NOT DEFINED baseScripts SET "baseScripts=\Distributives\Local_Scripts\software_update\Downloader"
)
(
    rem CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/pa/PAssist_Lite.exe PAssist_Lite.exe -N
    rem CALL "%baseScripts%\_DistDownload.cmd" "http://www2.aomeisoftware.com/download/pa/PAssist_Lite.exe?banner" PAssist_Lite.exe -N
    CALL "%baseScripts%\_DistDownload.cmd" "http://www2.aomeisoftware.com/download/pa/PAssist_Lite.exe" PAssist_Lite.exe -N
    rem CALL "%baseScripts%\_DistDownload.cmd" http://www.aomeisoftware.com/download/pa/PAssist_Std.exe PAssist_Std.exe -N
    CALL "%baseScripts%\_DistDownload.cmd" "http://www2.aomeisoftware.com/download/pa/PAssist_Std.exe" PAssist_Std.exe -N
    
    CALL FindAutoHotkeyExe.cmd "%~dp0link_to_version_subdir.ahk"
)
