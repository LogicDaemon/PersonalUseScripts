@REM coding:CP866

SET sp=Users\LogicDaemon\AppData
SET sd=d:
SET rd=r:

FOR /F "usebackq delims=] tokens=1" %%I IN (`FIND /N "---separator---" "%~f0"`) DO SET skip=%%I
SET /A skip=%skip:~1%

PUSHD "%sd%\%sp%"
    FOR /F "usebackq skip=%skip% tokens=1,2 eol=; delims=*" %%I IN ("%~f0") DO (
        FOR /D %%A IN ("%%~I*") DO IF /I "%%~xA" NEQ ".bak" CALL :MoveDirToRAMDrive "%%~A%%J"
    )
POPD

MKDIR "r:\Temp\Spring\Zero-K\cache"
EXIT /B

:MoveDirToRAMDrive <subdir path>
    MKDIR "%rd%\%sp%\%~1"
    IF EXIST "%%~A%%J\*" (
        IF NOT EXIST "%sd%\%sp%\%~1.bak" (
            MOVE /Y "%sd%\%sp%\%~1" "%sd%\%sp%\%~1.bak"
        ) ELSE (
            RD /S /Q "%sd%\%sp%\%~1"
        )
    )
    "%LocalAppData%\Programs\Total Commander\xln.exe" -n "%rd%\%sp%\%~1" "%sd%\%sp%\%~1"
EXIT /B

REM Dir list
REM ---separator---
Local\Packages\*\AC\INetCache
Local\Packages\*\AC\INetHistory
Local\Packages\*\AC\Temp
Local\Packages\*\LocalState\Cache
Local\Packages\*\LocalState\LiveTile
Local\Packages\*\TempState
Local\Programs\Tor Browser\Browser\TorBrowser\Data\Browser\Caches\

Roaming\NVIDIA
Roaming\Microsoft\Windows\Themes\CachedFiles
Local\Temp
; Local\Steam
; Local\NVIDIA\NvBackend
Local\Dropbox\logs
Local\Google\Chrome\User Data\Profile *\Cache
Local\Google\Chrome\User Data\Profile *\GPUCache
Local\Google\Chrome\User Data\Profile *\Media Cache
Local\Google\Chrome\User Data\Profile *\Service Worker
Local\Google\Chrome\User Data\Profile *\JumpListIcons
Local\Google\Chrome\User Data\Profile *\JumpListIconsOld
Local\Google\Chrome\User Data\Default\Cache
Local\Google\Chrome\User Data\Default\GPUCache
Local\Google\Chrome\User Data\Default\Media Cache
Local\Google\Chrome\User Data\Default\Service Worker
Local\Google\Chrome\User Data\Default\JumpListIcons
Local\Google\Chrome\User Data\Default\JumpListIconsOld
Local\Vivaldi\User Data\Profile *\Cache
Local\Vivaldi\User Data\Profile *\GPUCache
Local\Vivaldi\User Data\Profile *\Media Cache
Local\Vivaldi\User Data\Profile *\Service Worker
Local\Vivaldi\User Data\Profile *\JumpListIcons
Local\Vivaldi\User Data\Profile *\JumpListIconsOld
Local\Vivaldi\User Data\Default\Cache
Local\Vivaldi\User Data\Default\GPUCache
Local\Vivaldi\User Data\Default\Media Cache
Local\Vivaldi\User Data\Default\Service Worker
Local\Vivaldi\User Data\Default\JumpListIcons
Local\Vivaldi\User Data\Default\JumpListIconsOld
Local\Microsoft\Internet Explorer
Local\Microsoft\Media Player
;Local\Microsoft\Windows\Caches
Local\Microsoft\Windows\Explorer
Local\Microsoft\Windows\INetCache
Local\Microsoft\Windows\INetCookies
Local\Microsoft\Windows\Notifications
Local\Microsoft\Windows\WebCache
LocalLow
Local\Vivaldi\User Data\Profile *\Cache
Local\Vivaldi\User Data\Profile *\GPUCache
Local\Vivaldi\User Data\Profile *\Media Cache
Local\Vivaldi\User Data\Profile *\Service Worker
Local\Vivaldi\User Data\Profile *\JumpListIcons
Local\Vivaldi\User Data\Profile *\JumpListIconsOld
Local\Vivaldi\User Data\Default\Cache
Local\Vivaldi\User Data\Default\GPUCache
Local\Vivaldi\User Data\Default\Media Cache
Local\Vivaldi\User Data\Default\Service Worker
Local\Vivaldi\User Data\Default\JumpListIcons
Local\Vivaldi\User Data\Default\JumpListIconsOld
