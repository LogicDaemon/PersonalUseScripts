@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

	IF NOT DEFINED RAMDrive VOL R: | FIND " Volume in drive R is RamDisk" && SET "RAMDrive=r:"
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
	IF DEFINED vscodeRemoteWSLDist MKLINK /J "%RAMDrive%\Temp\vscode-remote-wsl" "%vscodeRemoteWSLDist%"
	IF EXIST d:\elevoc_dnn_kernel.log ECHO.>"%RAMDrive%\elevoc_dnn_kernel.log"

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

	IF EXIST "c:\Intel\IntelOptaneData" MKDIR "%RAMDrive%\Intel\IntelOptaneData"

	IF EXIST "%ProgramData%\GOG.com" (
		MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\webcache\common"
		MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\lock-files"
		MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\logs"
		MKDIR "%RAMDrive%\ProgramData\GOG.com\Galaxy\crashdumps"
	)
	IF EXIST "%ProgramData%\Dropbox" MKDIR "%RAMDrive%\ProgramData\Dropbox\Update\Log"
	
	IF EXIST "%ProgramData%\NVIDIA Corporation" (
		IF EXIST "%ProgramData%\NVIDIA Corporation\NVIDIA app" (
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\Installer\Logs"
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\Logs"
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\MessageBus"
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\NvContainer"
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\SessionLogs"
			MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA app\UXD"
		)
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\CrashDumps"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\DisplayDriverRAS"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\Drs"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\FrameViewSDK"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\GameSessionTelemetry"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\GfnRuntimeSdk"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA Broadcast"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NVIDIA GeForce Experience"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NvProfileUpdaterPlugin"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NvTelemetry"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\nvtopps"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\NvVAD"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\RX"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\ShadowPlay"
		MKDIR "%RAMDrive%\ProgramData\NVIDIA Corporation\umdlogs"
	)

	@REM CALL :MkDirsWithCopiedPermissions "%SystemRoot%" "%RAMDrive%" ServiceProfiles LocalService AppData Local Temp
	CALL :MoveLinkBack "%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\Temp\TfsStore" "%RAMDrive%\ServiceProfiles\LocalService\AppData\Local\Temp\TfsStore"

	IF NOT EXIST "%USERPROFILE%" EXIT /B
	IF NOT EXIST "%LOCALAPPDATA%" EXIT /B

	rem DO NOT link %LOCALAPPDATA%\Temp to RamDisk. Just update the env var (outside of this script).
	REM if it's a link, it will be removed and re-created as an empty dir;
	REM if it's a dir without contents, same
	REM but if it's non-empty dir, it will stay as is (note lack of "/S")
	rem RD /Q "%LOCALAPPDATA%\Temp"
	REM this is needed because now the directory will be moved to R:, and if it's a link to R:, that might break MOVE which will move files to themselves and then remove from source (but as it's linked to dest, remove that single copy altogether)
	rem IF NOT EXIST "%LOCALAPPDATA%\Temp" CALL :MoveLinkBack "%LOCALAPPDATA%\Temp" "%RAMDrive%\Temp"

	CALL :MoveToRAMDrive "%USERPROFILE%\.cache"

	rem CALL :MoveToRAMDrive "%APPDATA%\AppData\LocalLow\LocalLow"
	CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\webviewdata"
	IF EXIST "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment" (
		CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\cache"
		CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\tmp"
		CALL :MoveToRAMDrive "%USERPROFILE%\AppData\LocalLow\Sun\Java\Deployment\log"
	)

	REM DLLs there
	rem CALL :MoveToRAMDrive "%USERPROFILE%\.openjfx\cache"

	SET "keepRenamed=1"
	IF EXIST "c:\OEM\AcerLogs" CALL :MoveToRAMDrive "c:\OEM\AcerLogs"
	IF EXIST "c:\OEM\CareCenter" CALL :MoveToRAMDrive "c:\OEM\CareCenter"
	IF EXIST "c:\OEM\Preload" CALL :MoveToRAMDrive "c:\OEM\Preload"

	FOR %%B IN (Pictures Videos Music "My SecuriSync") DO @IF EXIST "%USERPROFILE%\%%~B\.SecuriSync" CALL :MoveToRAMDrive "%USERPROFILE%\%%~B\.SecuriSync\Spool Files"
	IF EXIST "%APPDATA%\npm-cache" CALL :MoveToRAMDrive "%APPDATA%\npm-cache"

	IF EXIST "%APPDATA%\obs-studio" (
		CALL :MoveToRAMDrive "%APPDATA%\obs-studio\crashes"
		CALL :MoveToRAMDrive "%APPDATA%\obs-studio\logs"
		CALL :MoveToRAMDrive "%APPDATA%\obs-studio\profiler_data"
		CALL :MoveToRAMDrive "%APPDATA%\obs-studio\updates"
	)

	rem Electron apps
	FOR /D %%B IN ("%APPDATA%\Beyond-All-Reason" ^
		       "%APPDATA%\Code - Insiders" ^
		       "%APPDATA%\Code" ^
		       "%APPDATA%\Cursor" ^
		       "%APPDATA%\discord" ^
		       "%APPDATA%\Dropbox" ^
		       "%APPDATA%\Dropbox\Partitions\*.*" ^
		       "%APPDATA%\Intermedia Unite" ^
		       "%APPDATA%\obs-studio\plugin_config\obs-browser" ^
		       "%APPDATA%\obs-studio\plugin_config\obs-browser\obs_profile_cookies\*" ^
		       "%APPDATA%\update-hub" ^
		      ) DO @(
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
rem					    "WebStorage" ^
		) DO @(
			IF EXIST "%%~B\%%~C" CALL :MoveToRAMDrive "%%~B\%%~C"
		)
	)

	IF EXIST "%LOCALAPPDATA%\AMD" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\AMD\DxCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\AMD\DxcCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\AMD\OglCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\AMD\VkCache"
	)
	IF EXIST "%LOCALAPPDATA%\opencode" MKLINK /J "%USERPROFILE%\.cache\opencode" "%LOCALAPPDATA%\opencode\cache"
	IF EXIST "%LOCALAPPDATA%\NVIDIA Corporation" (
		MKDIR "%RAMDrive%\Temp\NVIDIA Corporation\NV_Cache"
		COMPACT /U "%RAMDrive%\Temp\NVIDIA Corporation"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Notification"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\Cache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\Code Cache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\NVIDIA Corporation\NVIDIA Share\CefCache\GPUCache"
	)

	IF EXIST "%LOCALAPPDATA%\cache" CALL :MoveToRAMDrive "%LOCALAPPDATA%\cache"
	IF EXIST "%LOCALAPPDATA%\CrashDumps" CALL :MoveToRAMDrive "%LOCALAPPDATA%\CrashDumps"
	IF EXIST "%LOCALAPPDATA%\NuGet" CALL :MoveToRAMDrive "%LOCALAPPDATA%\NuGet"
	IF EXIST "%LOCALAPPDATA%\Google\YAPF" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Google\YAPF\Cache"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Edge" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Edge"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Internet Explorer" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Internet Explorer"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Media Player" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Media Player"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Olk" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Olk\cache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Olk\logs"
	)
	IF EXIST "%LOCALAPPDATA%\Microsoft\OneDrive" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\OneDrive\logs"
	IF EXIST "%LOCALAPPDATA%\Microsoft\OneDrive\setup" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\OneDrive\setup\logs"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Terminal Server Client" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Terminal Server Client\Cache"
	IF EXIST "%LOCALAPPDATA%\Microsoft\Windows" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Explorer"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\INetCookies"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\Notifications"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Microsoft\Windows\WebCache"
	)

	IF EXIST "%LOCALAPPDATA%\Dropbox" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\avatar_cache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\Crashpad"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\CrashReports"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\events"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\exceptions"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\metrics"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\QuitReports"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Dropbox\logs"
	)
	IF EXIST "%LOCALAPPDATA%\DropboxUpdate" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\DropboxUpdate\CrashReports"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\DropboxUpdate\Update\Download"
	)
	IF EXIST "%LOCALAPPDATA%\Jedi" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Jedi"
	IF EXIST "%LOCALAPPDATA%\Kalypso Media" CALL :MoveToRAMDrive "%LOCALAPPDATA%\Kalypso Media"
	IF EXIST "%LOCALAPPDATA%\kdenlive" CALL :MoveToRAMDrive "%LOCALAPPDATA%\kdenlive"
	IF EXIST "%LOCALAPPDATA%\MAGIX" CALL :MoveToRAMDrive "%LOCALAPPDATA%\MAGIX"
	IF EXIST "%LOCALAPPDATA%\MusicMaker" CALL :MoveToRAMDrive "%LOCALAPPDATA%\MusicMaker"
	IF EXIST "%LOCALAPPDATA%\Battle.net" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\BrowserCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Battle.net\Cache"
	)
	IF EXIST "%LOCALAPPDATA%\CD Projekt Red" CALL :MoveToRAMDrive "%LOCALAPPDATA%\CD Projekt Red\Cyberpunk 2077\cache"
	rem CALL :MoveToRAMDrive "%LOCALAPPDATA%\pip"
	IF EXIST "%LOCALAPPDATA%\Steam" (
		MKDIR "%RAMDrive%\Steam\appcache\httpcache"
		MKDIR "%RAMDrive%\Steam\depotcache"
		MKDIR "%RAMDrive%\Steam\dumps"
		MKDIR "%RAMDrive%\Steam\GPUCache"
		MKDIR "%RAMDrive%\Steam\htmlcache"
		MKDIR "%RAMDrive%\Steam\logs"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Steam"
	)
	IF EXIST "%LOCALAPPDATA%\VEGAS" CALL :MoveToRAMDrive "%LOCALAPPDATA%\VEGAS"
	IF EXIST "%LOCALAPPDATA%\Programs\Tor Browser" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\Caches"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\storage"
	)
	IF EXIST "%LOCALAPPDATA%\Programs\jdownloader" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\jdownloader\logs"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\jdownloader\tmp"
	)
	IF EXIST "%LOCALAPPDATA%\Programs\TeamSpeak" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\crashdumps"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\logs"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_cache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\GPUCache"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\Platform Notifications"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\Programs\TeamSpeak\config\qtwebengine_persistant_storage\Session Storage"
	)
	IF EXIST "%LOCALAPPDATA%\EpicGamesLauncher" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\Config\CrashReportClient"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\Logs"
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\EpicGamesLauncher\Saved\webcache_4430"
	)
	IF EXIST "%LOCALAPPDATA%\nomic.ai\GPT4All" (
		CALL :MoveToRAMDrive "%LOCALAPPDATA%\nomic.ai\GPT4All"
		REM %USERPROFILE%\.cache\gpt4all\ contains downloaded gguf files, so they should be linked back to avoid wasting multi-gb downloads
		FOR %%D IN ("%USERPROFILE%\GPT4All\Models" ^
			    "d:\Distributives\LLMs\gguf" ^
		) DO @IF EXIST "%%~D" MKLINK /J "%USERPROFILE%\.cache\gpt4all" "%%~D"
	)
	
	FOR /D %%P IN ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") DO @CALL :MoveToRAMDrive "%%~P"
	
	rem Profiles in Chome-based apps
	FOR %%B IN ("%LOCALAPPDATA%\Google\Chrome" ^
				"%LOCALAPPDATA%\Google\Chrome Beta" ^
				"%LOCALAPPDATA%\Chromium" ^
				"%LOCALAPPDATA%\Vivaldi" ^
				"%LOCALAPPDATA%\Microsoft\Olk\EBWebView" ^
			   ) DO @(
		IF EXIST "%%~B\User Data" (
			CALL :MoveToRAMDrive "%%~B\User Data\GraphiteDawnCache"
			CALL :MoveToRAMDrive "%%~B\User Data\GrShaderCache"
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
	)
	rem Windows AppX tempfiles
	FOR /D %%P IN ("%LOCALAPPDATA%\Packages\*") DO @(
		CALL :MoveToRAMDrive "%%~P\AC\INetCache"
		CALL :MoveToRAMDrive "%%~P\AC\INetHistory"
		CALL :MoveToRAMDrive "%%~P\AC\Temp"
		CALL :MoveToRAMDrive "%%~P\LocalState\Cache"
		CALL :MoveToRAMDrive "%%~P\LocalState\LiveTile"
		CALL :MoveToRAMDrive "%%~P\TempState"
	)

	EXIT /B
)
:MoveToRAMDrive <src_path> <dest_drive>
@(
	IF "%~2"=="" ( CALL :MoveLinkBack %1 "%RAMDrive%%~pnx1" ) ELSE ( CALL :MoveLinkBack %1 "%~2%~nx1" )
EXIT /B
)
:MoveLinkBack <source> <destination>
(
	IF NOT DEFINED forceRelink IF EXIST %1 (
		REM Check if it's linked already and skip if it is
		DIR /AL %1 && EXIT /B
	)
	CALL :MkdirMissingBaseDirWithPermissions %1 %2
	IF NOT EXIST %2 MKDIR %2
	IF EXIST %1 (
		REM Try removing an empty dir/junction
		IF NOT EXIST "%~1\*.*" RD /Q %1
		REM maybe it's a symlink
		IF EXIST %1 ECHO N|DEL %1
		IF EXIST %1 (
			REM It still exists, so it seems to be a legit non-empty directory
			MOVE %1 "%~1.LINKED_%DATE:/=%_%TIME::=%" || EXIT /B
			IF NOT "%keepRenamed%"=="1" START "" /B %comspec% /C "RD /S /Q "%~1.LINKED_%DATE:/=%_%TIME::=%""
		)
	) ELSE IF NOT EXIST "%~dp1" MKDIR "%~dp1"
	ECHO Linking %2 to %1
	MKLINK /J %1 %2 || MKLINK /D %1 %2
EXIT /B
)
:MkdirMissingBaseDirWithPermissions <source> <destination>
@(
	SET "sourceDir=%~dp1"
	SET "destinationDir=%~dp2"
)
@(
	IF "%sourceDir:~-1%"=="\" SET "sourceDir=%sourceDir:~0,-1%"
	IF "%destinationDir:~-1%"=="\" SET "destinationDir=%destinationDir:~0,-1%"
)
@REM if parents do not exist, deal with them first
@IF NOT EXIST "%destinationDir%" CALL :MkdirMissingBaseDirWithPermissions "%sourceDir%" "%destinationDir%"
:CopyDirPermissions <source> <destination>
@(
	IF DEFINED aclfile GOTO :CopyDirPermissionsTmpPathDefined
	SET "s=%RANDOM%"
)
@(
	IF EXIST "%RAMDrive%\Temp\acl%s%.tmp" GOTO :CopyDirPermissions
	SET "aclfile=%RAMDrive%\Temp\acl%s%.tmp"
	SET s=
)
:CopyDirPermissionsTmpPathDefined
@(
	IF NOT EXIST %2 MKDIR %2 || EXIT /B
	PUSHD "%~1" || EXIT /B
	icacls . /save "%aclfile%" || (
		DEL "%aclfile%"
		EXIT /B
	)
	POPD
	PUSHD "%~2" || EXIT /B
	icacls . /restore "%aclfile%" || ECHO Error restoring permissions on "%~2">&2
	POPD
	DEL "%aclfile%"
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
