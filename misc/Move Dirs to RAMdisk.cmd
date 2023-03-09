@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    SET "RAMDrive=r:"
    rem SET "USERPROFILE=d:\Users\LogicDaemon"
    rem SET "APPDATA=%USERPROFILE%\AppData\Roaming"
    rem SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"
    IF EXIST "%LocalAppData%\Programs\bin\xln.exe" SET xlnexe="%LocalAppData%\Programs\bin\xln.exe"
    SET "retries=30"
)
:again
@(
    IF NOT EXIST "%RAMDrive%\" (
        IF %retries% LSS 0 EXIT /B 1
        SET /A "retries-=1"
        PING -n 2 127.0.0.1 >NUL
        GOTO :again
    )
    ATTRIB +I "%RAMDrive%\*.*" /S /D /L

    REM if it's a link, it will be removed and re-created as an empty dir;
    REM if it's a dir without contents, same
    REM but if it's non-empty dir, it will stay as is (note lack of "/S")
    RD /Q "%LOCALAPPDATA%\Temp"
    REM this is needed because now the directory will be moved to R:, and if it's a link to R:, that might break MOVE which will move files to themselves and then remove from source (but as it's linked to dest, remove that single copy altogether)
    CALL :LinkBack "%LOCALAPPDATA%\Temp" "r:\Temp"

    MKDIR "%RAMDrive%\Temp\NVIDIA Corporation\NV_Cache"
    COMPACT /U "%RAMDrive%\Temp\NVIDIA Corporation"

    IF NOT EXIST "%USERPROFILE%" EXIT /B

    MKDIR "%RAMDrive%\Temp\obs-studio\crashes"
    MKDIR "%RAMDrive%\Temp\obs-studio\plugin_config\obs-browser"
    MKDIR "%RAMDrive%\Temp\obs-studio\plugin_config\obs-browsers"
    MKDIR "%RAMDrive%\Steam\appcache"
    MKDIR "%RAMDrive%\Steam\appcache\httpcache"
    MKDIR "%RAMDrive%\Steam\htmlcache"
    MKDIR "%RAMDrive%\Temp\RivetNetworks\ImageCache"
    MKDIR "%RAMDrive%\Temp\RivetNetworks\Killer\ActivityLog"
    
    MKDIR "%RAMDrive%\Temp\OEM\AcerLogs"
    MKDIR "%RAMDrive%\Temp\OEM\CareCenter"
    MKDIR "%RAMDrive%\Temp\OEM\Preload"
    rem CALL :MoveToRAMDrive "c:\OEM\AcerLogs"
    rem CALL :MoveToRAMDrive "c:\OEM\CareCenter"
    rem CALL :MoveToRAMDrive "c:\OEM\Preload"

    CALL :MoveToRAMDrive "%APPDATA%\discord\Cache"
    CALL :MoveToRAMDrive "%APPDATA%\discord\Code Cache"
    CALL :MoveToRAMDrive "%APPDATA%\DropboxElectron"
    CALL :MoveToRAMDrive "%APPDATA%\npm-cache"    
    
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Internet Explorer"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Media Player"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Explorer"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCookies"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Notifications"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\WebCache"

    rem CALL :MoveToRAMDrive "%APPDATA%\..\LocalLow"
    CALL :MoveToRAMDrive "%USERPROFILE%\.cache"
    CALL :MoveToRAMDrive "%USERPROFILE%\.openjfx\cache"
    
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\BrowserCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\Cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077\cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\avatar_cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\Crashpad"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\CrashReports"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\events"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\exceptions"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\metrics"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\QuitReports"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Jedi"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Kalypso Media"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\kdenlive"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\MAGIX"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\MusicMaker"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\NuGet"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Notification"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\Cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\Code Cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\GPUCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\pip"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Steam"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\VEGAS"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\Caches"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\storage"
        
rem     CALL :MoveToRAMDrive 
    
    FOR /D %%P IN ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") DO CALL :MoveToRAMDrive "%%~P"
    FOR /D %%P IN ("%LOCALAPPDATA%\Packages\*") DO (
        CALL :MoveToRAMDrive "%%~P\AC\INetCache"
        CALL :MoveToRAMDrive "%%~P\AC\INetHistory"
        CALL :MoveToRAMDrive "%%~P\AC\Temp"
        CALL :MoveToRAMDrive "%%~P\LocalState\Cache"
        CALL :MoveToRAMDrive "%%~P\LocalState\LiveTile"
        CALL :MoveToRAMDrive "%%~P\TempState"
    )
    
    FOR %%B IN ("%LOCALAPPDATA%\Google\Chrome" "%LOCALAPPDATA%\Google\Chrome Beta" "%LOCALAPPDATA%\Chromium" "%LOCALAPPDATA%\Vivaldi") DO @(
        FOR /D %%P IN ("%%~B\User Data\Default" "%%~B\User Data\Profile *") DO @(
            FOR /D %%E IN ("%%~P" "%%~P\Storage\ext\*") DO (
                FOR /F "usebackq delims=" %%A IN ("%~dp0Chrome_Profile_Temporary.txt") DO IF EXIST "%%~E\%%~A" CALL :MoveToRAMDrive "%%~E\%%~A"
            )
        )
    )
    CALL :CopyPermissions "%USERPROFILE%"
    EXIT /B
)
:MoveToRAMDrive <src_path> <dest_drive>
(
    IF "%~2"=="" ( CALL :LinkBack %1 "%RAMDrive%%~pnx1" ) ELSE ( CALL :LinkBack %1 "%~2%~pnx1" )
EXIT /B
)
:CopyPermissions <src_path> <dest_drive>
(
    IF "%~2"=="" ( XCOPY %1 "%RAMDrive%%~pnx1" /Y /T /E /O /U /K /B ) ELSE ( XCOPY %1 "%~2%~pnx1" /Y /T /E /O /U /K /B )
EXIT /B
)
:LinkBack <source> <destination>
(
    IF EXIST "%~1\*" IF NOT EXIST %2 (
	IF NOT EXIST "%~dp2" MKDIR "%~dp2"
	IF NOT EXIST "%~dp2" EXIT /B
	MOVE /Y %1 %2
    )
    IF NOT EXIST %2 MKDIR %2
    IF NOT EXIST %2 EXIT /B
    RD /Q %1
    MKLINK /D %1 %2 || MKLINK /J %1 %2 || IF DEFINED xlnexe (
        %xlnexe% -n %2 %1 || (
            RD /S /Q %1
            xln.exe -n %2 %1
        )
    )
EXIT /B
)
