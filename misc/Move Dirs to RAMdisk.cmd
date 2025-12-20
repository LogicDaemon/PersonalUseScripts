@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    VOL R: | FIND " Volume in drive R is RamDisk" && SET "RAMDrive=r:"
    IF NOT DEFINED RAMDrive VOL R: | FIND " Volume in drive R is RAM disk" && SET "RAMDrive=r:"
    IF NOT DEFINED RAMDrive EXIT /B 1
    
    rem SET "USERPROFILE=d:\Users\LogicDaemon"
    rem SET "APPDATA=%USERPROFILE%\AppData\Roaming"
    rem SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"

    SET "vscodeRemoteWSLDistSubdir=Soft FOSS\Office Text Publishing\Text Documents\Visual Studio Code Addons\Remote Server\vscode-remote-wsl"
)
@(
    CALL "%~dp0_Distributives.find_subpath.cmd" Distributives "%vscodeRemoteWSLDistSubdir%"
    IF DEFINED Distributives IF EXIST %Distributives%\%vscodeRemoteWSLDistSubdir% SET "vscodeRemoteWSLDist=%Distributives%\%vscodeRemoteWSLDistSubdir%"

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

    MKDIR "%RAMDrive%\Temp\NVIDIA Corporation\NV_Cache"
    COMPACT /U "%RAMDrive%\Temp\NVIDIA Corporation"

    IF EXIST "c:\Intel" MKDIR "%RAMDrive%\Intel\IntelOptaneData"
    
    MKDIR "%RAMDrive%\Steam\appcache\httpcache"
    MKDIR "%RAMDrive%\Steam\depotcache"
    MKDIR "%RAMDrive%\Steam\dumps"
    MKDIR "%RAMDrive%\Steam\GPUCache"
    MKDIR "%RAMDrive%\Steam\htmlcache"
    MKDIR "%RAMDrive%\Steam\logs"
    MKDIR "%RAMDrive%\Temp\.mypy_cache"
    MKDIR "%RAMDrive%\Temp\_tc"
    MKDIR "%RAMDrive%\Temp\cache"
    MKDIR "%RAMDrive%\Temp\Diagnostics"
    MKDIR "%RAMDrive%\Temp\DiagOutputDir"
    MKDIR "%RAMDrive%\Temp\GHISLER"
    MKDIR "%RAMDrive%\Temp\NvTelemetry_WD"
    MKDIR "%RAMDrive%\Temp\obs-studio\crashes"
    MKDIR "%RAMDrive%\Temp\obs-studio\plugin_config\obs-browser"
    MKDIR "%RAMDrive%\Temp\obs-studio\plugin_config\obs-browsers"
    MKDIR "%RAMDrive%\Temp\OEM\AcerLogs"
    MKDIR "%RAMDrive%\Temp\OEM\CareCenter"
    MKDIR "%RAMDrive%\Temp\OEM\Preload"
    MKDIR "%RAMDrive%\Temp\Outlook Logging"
    MKDIR "%RAMDrive%\Temp\RivetNetworks\ImageCache"
    MKDIR "%RAMDrive%\Temp\RivetNetworks\Killer\ActivityLog"
    MKDIR "%RAMDrive%\Temp\SecuriSyncDiagnosticReport"

    IF EXIST "%ProgramData%\GOG.com" (
        MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\webcache\common"
        MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\lock-files"
        MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\logs"
        MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\crashdumps"
    )
    IF EXIST "%ProgramData%\NVIDIA Corporation\NVIDIA app" (
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\Installer\Logs"
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\Logs"
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\MessageBus"
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\NvContainer"
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\SessionLogs"
        MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\UXD"
    )
    IF EXIST "%ProgramData%\Dropbox" MKDIR "%RAMDrive%\ProgramData\Dropbox\Update\Log"
    
    @REM CALL :MkDirsWithCopiedPermissions "%SystemRoot%" "%RAMDrive%" ServiceProfiles LocalService AppData Local Temp
    CALL :MoveLinkBack "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\Temp\TfsStore" "%RAMDrive%\ServiceProfiles\LocalService\AppData\Local\Temp\TfsStore"

    IF NOT EXIST "%USERPROFILE%" EXIT /B
    IF NOT EXIST "%LOCALAPPDATA%" EXIT /B

    REM if it's a link, it will be removed and re-created as an empty dir;
    REM if it's a dir without contents, same
    REM but if it's non-empty dir, it will stay as is (note lack of "/S")
    RD /Q "%LOCALAPPDATA%\Temp"
    REM this is needed because now the directory will be moved to R:, and if it's a link to R:, that might break MOVE which will move files to themselves and then remove from source (but as it's linked to dest, remove that single copy altogether)
    CALL :MoveLinkBack "%LOCALAPPDATA%\Temp" "r:\Temp"
    IF DEFINED vscodeRemoteWSLDist MKLINK /J "r:\Temp\vscode-remote-wsl" "%vscodeRemoteWSLDist%"

    SET "tryRenaming=1"
    IF EXIST "%USERPROFILE%\My SecuriSync" CALL :MoveToRAMDrive "%USERPROFILE%\My SecuriSync\.SecuriSync\Spool Files"
    IF EXIST "c:\OEM\AcerLogs" CALL :MoveToRAMDrive "c:\OEM\AcerLogs"
    IF EXIST "c:\OEM\CareCenter" CALL :MoveToRAMDrive "c:\OEM\CareCenter"
    IF EXIST "c:\OEM\Preload" CALL :MoveToRAMDrive "c:\OEM\Preload"
    IF EXIST "%APPDATA%\npm-cache" CALL :MoveToRAMDrive "%APPDATA%\npm-cache"
    CALL :MoveToRAMDrive "%APPDATA%\obs-studio\crashes"
    CALL :MoveToRAMDrive "%APPDATA%\obs-studio\logs"
    CALL :MoveToRAMDrive "%APPDATA%\obs-studio\profiler_data"
    CALL :MoveToRAMDrive "%APPDATA%\obs-studio\updates"
    
    rem Electron apps
    FOR /D %%B IN ("%APPDATA%\Beyond-All-Reason" ^
                   "%APPDATA%\Dropbox" ^
                   "%APPDATA%\Code" ^
                   "%APPDATA%\Code - Insiders" ^
                   "%APPDATA%\Cursor" ^
                   "%APPDATA%\update-hub" ^
                   "%APPDATA%\discord" ^
                   "%APPDATA%\obs-studio\plugin_config\obs-browser" ^
                   "%AppData%\Dropbox\Partitions\*.*" ^
                   "%APPDATA%\obs-studio\plugin_config\obs-browser\obs_profile_cookies\*") DO @(
        IF EXIST "%%~B" FOR %%C IN ("Cache" ^
                                    "CachedData" ^
                                    "CachedExtensions" ^
                                    "CachedProfilesData" ^
                                    "Code Cache" ^
                                    "Crashpad" ^
                                    "DawnCache" ^
                                    "DawnGraphiteCache" ^
                                    "DawnWebGPUCache" ^
                                    "GPUCache" ^
                                    "GrShaderCache" ^
                                    "logs" ^
                                    "Service Worker\CacheStorage" ^
                                    "Service Worker\ScriptCache" ^
                                    "Shared Dictionary\cache" ^
                                    "Session Storage" ^
                                    "ShaderCache" ^
rem                                     "WebStorage" ^
                                   ) DO @(
            IF EXIST "%%~B\%%~C" CALL :MoveToRAMDrive "%%~B\%%~C"
        )
    )
    
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Google\YAPF\Cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Edge"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Internet Explorer"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Media Player"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Explorer"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCookies"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Notifications"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\WebCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Olk\cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Olk\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Olk\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\OneDrive\setup\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\OneDrive\logs"

    rem CALL :MoveToRAMDrive "%APPDATA%\AppData\LocalLow\LocalLow"
    CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\webviewdata"
    CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\cache"
    CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\tmp"
    CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\log"
    CALL :MoveToRAMDrive "%USERPROFILE%\.cache"
    
    REM DLLs there
    rem CALL :MoveToRAMDrive "%USERPROFILE%\.openjfx\cache"
    
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\BrowserCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\Cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077\cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\CrashDumps"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\avatar_cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\Crashpad"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\CrashReports"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\events"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\exceptions"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\metrics"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\QuitReports"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\DropboxUpdate\CrashReports"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\DropboxUpdate\Update\Download"
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
    rem CALL :MoveToRAMDrive "%LOCALAPPDATA%\pip"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Steam"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\VEGAS"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\Caches"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\storage"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\jdownloader\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\jdownloader\tmp"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\crashdumps"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_cache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\GPUCache"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\Platform Notifications"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\Session Storage"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\Config\CrashReportClient"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\Logs"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\webcache_4430"
    CALL :MoveToRAMDrive "%LOCALAPPDATA%\nomic.ai\GPT4All"
    
rem     CALL :MoveToRAMDrive 
    
    FOR /D %%P IN ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") DO @CALL :MoveToRAMDrive "%%~P"
    
    FOR %%B IN ("%LOCALAPPDATA%\Google\Chrome" ^
                "%LOCALAPPDATA%\Google\Chrome Beta" ^
                "%LOCALAPPDATA%\Chromium" ^
                "%LOCALAPPDATA%\Vivaldi" ^
                "%LOCALAPPDATA%\Microsoft\Olk\EBWebView" ^
               ) DO @(
        FOR /D %%P IN ("%%~B\User Data\Default" "%%~B\User Data\Profile *") DO @(
            FOR /D %%E IN ("%%~P" "%%~P\Storage\ext\*") DO (
                FOR /F "usebackq delims=" %%A IN ("%~dp0Chrome_Profile_Temporary.txt") DO @(
                    MKDIR "%%~E\%%~A"
                    CALL :MoveToRAMDrive "%%~E\%%~A"
                )
            )
        )
        CALL :MoveToRAMDrive "%%~B\User Data\Guest Profile"
        FOR /D %%C IN ("%%~B\User Data\Crashpad" "%%~B\User Data\ShaderCache") DO @(
            IF EXIST "%%~C" CALL :MoveToRAMDrive "%%~C"
        )
    )

    SET "tryRenaming="
    FOR /D %%P IN ("%LOCALAPPDATA%\Packages\*") DO @(
        CALL :MoveToRAMDrive "%%~P\AC\INetCache"
        CALL :MoveToRAMDrive "%%~P\AC\INetHistory"
        CALL :MoveToRAMDrive "%%~P\AC\Temp"
        CALL :MoveToRAMDrive "%%~P\LocalState\Cache"
        CALL :MoveToRAMDrive "%%~P\LocalState\LiveTile"
        CALL :MoveToRAMDrive "%%~P\TempState"
    )

    REM %USERPROFILE%\.cache\gpt4all\ contains downloaded gguf files, so they should be linked back to avoid wasting multi-gb downloads
    rem FOR %%D IN ("d:\Users\LogicDaemon\GPT4All\Models" ^
    rem 	    "%USERPROFILE%\GPT4All\Models" ^
    rem 	    "V:\Distributives\LLMs\gguf" ^
    rem 	    "d:\Distributives\LLMs\gguf" ^
    rem 	   ) DO @(
    rem     IF EXIST "%%~D" MKLINK /J "%USERPROFILE%\.cache\gpt4all" "%%~D"
    rem )

    EXIT /B
)
:MoveToRAMDrive <src_path> <dest_drive>
@(
    IF "%~2"=="" ( CALL :MoveLinkBack %1 "%RAMDrive%%~pnx1" ) ELSE ( CALL :MoveLinkBack %1 "%~2%~nx1" )
EXIT /B
)
:MoveLinkBack <source> <destination>
(
    CALL :MkdirMissingTreeWithPermissions %1 %2
    IF NOT EXIST %2 MKDIR %2 || EXIT /B
    IF EXIST %1 RD /Q %1
    IF EXIST %1 ECHO N|DEL %1
    IF DEFINED tryRenaming IF EXIST %1 MOVE %1 "%1.LINKED_FROM_RAM_DISK_%DATE%_%TIME::=%" || EXIT /B
    IF EXIST %1 EXIT /B
    MKLINK /D %1 %2 || MKLINK /J %1 %2
EXIT /B
)
:MkdirMissingTreeWithPermissions <source> <destination>
@(
    SET "sourceDir=%~dp1"
    SET "destinationDir=%~dp2"
)
@(
    IF "%sourceDir:~-1%"=="\" SET "sourceDir=%sourceDir:~0,-1%"
    IF "%destinationDir:~-1%"=="\" SET "destinationDir=%destinationDir:~0,-1%"
)
@IF NOT EXIST "%destinationDir%" CALL :MkdirMissingTreeWithPermissions "%sourceDir%" "%destinationDir%"
:CopyDirPermissions <source> <destination>
@(
    IF DEFINED acfile GOTO :CopyDirPermissionsTmpPathDefined
    SET "s=%RANDOM%"
)
@(
    IF EXIST "%RAMDrive%\Temp\acl%s%.tmp" GOTO :CopyDirPermissions
    SET "aclfile=%RAMDrive%\Temp\acl%s%.tmp"
    SET s=
)
:CopyDirPermissionsTmpPathDefined
@(
    IF NOT EXIST %2 MKDIR %2
    PUSHD "%~1" && (
        icacls . /save "%aclfile%"
        POPD
        PUSHD "%~2" || EXIT /B
        icacls . /restore "%aclfile%"
        POPD
        DEL "%aclfile%"
    )
    EXIT /B
)
:MkDirsWithCopiedPermissions <source> <destination> <directories>
(
    SETLOCAL ENABLEEXTENSIONS
    IF NOT EXIST %2 MKDIR %2
    SET "subDir=%~3"
)
:MkDirsWithCopiedPermissionsLoop
(
    IF NOT EXIST "%~2\%subDir%" MKDIR "%~2\%subDir%"
    PUSHD "%~1\%subDir%" && (
        icacls . /save "%RAMDrive%\Temp\acl.tmp"
        POPD && ^
        PUSHD "%~2\%subDir%" && (
            icacls . /restore "%RAMDrive%\Temp\acl.tmp"
            POPD
        )
        DEL "%RAMDrive%\Temp\acl.tmp"
    )
    @REM doesn't work: ECHO F|XCOPY /D "%~1\%subDir%" "%~2\%subDir%" /-I /Y /T /O /K /B
    IF "%~4"=="" EXIT /B
    SET "subDir=%subdir%\%~4"
    SHIFT /4
    GOTO :MkDirsWithCopiedPermissionsLoop
)
