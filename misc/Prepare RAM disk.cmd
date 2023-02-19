@(REM coding:OEM
ECHO OFF

rem CALL :ParsePath "%USERPROFILE%\AppData"
CALL :ParsePath "d:\Users\LogicDaemon\AppData"
SET "rd=r:"

FOR /F "usebackq delims=] tokens=1" %%I IN (`FIND /N "---separator---" "%~f0"`) DO SET "skip=%%I"

ECHO ON
)
(
SET /A "skip=%skip:~1%"
IF EXIST %rd%\ (
    ECHO %rd%\ already exists & PAUSE
    imdisk -d -m %rd%
)
imdisk -a -m %rd% -t file -f "%ProgramData%\imdisk\imdisk_ramdisk.img" -s 4G -o rem,hd -p "/q /y /FS:NTFS /C /V:RAMdisk" || PAUSE
format %rd% /q /FS:NTFS /C /V:RAMdisk
rem "%ProgramFiles%\ImDisk\RamDyn.exe" "R:" 8388608 -1 0 12 "-p \"/fs:ntfs /q /y /V:RAMdisk\""
chkdsk %rd% /L
chkdsk %rd% /L:2048
chkdsk %rd% /L

MKDIR "%rd%%sp%"

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD
SET "aclDir=%sp%"
)
:ACLnextDir
FOR /F "delims=\ tokens=1*" %%A IN ("%aclDir%") DO (
    SET "subpath=!subpath!\%%A"
rem     XCOPY "%sd%!subpath!" "%rd%!subpath!" /T /O /I
    icacls "%sd%!subpath!" /save "%LOCALAPPDATA%\temp.ACL"
    icacls "%rd%!subpath!\.." /restore "%LOCALAPPDATA%\temp.ACL"
    SET "aclDir=%%~B"
)
(
IF NOT "%aclDir%"=="" GOTO :ACLnextDir
DEL "%LOCALAPPDATA%\temp.ACL"
POPD
ENDLOCAL

PUSHD "%sd%%sp%" && (
    FOR /F "usebackq skip=%skip% tokens=1,2 eol=; delims=*" %%I IN ("%~f0") DO (
        CALL :MoveDirToRAMDrive "%%~I%%~J"
        FOR /D %%A IN ("%%~I*") DO IF /I "%%~xA" NEQ ".bak" CALL :MoveDirToRAMDrive "%%~A%%J"
    )
POPD
)

imdisk -d -m %rd% || PAUSE
COMPACT /C "%ProgramData%\imdisk\imdisk_ramdisk.img"
imdisk -a -m %rd% -t vm -f "%ProgramData%\imdisk\imdisk_ramdisk.img" -o fix,hd || PAUSE

EXIT /B
) >>d:\Users\LogicDaemon\AppData\Local\imdisk_ramdisk.creating.log 2>&1

:MoveDirToRAMDrive <subdir path>
(
    IF NOT EXIST "%rd%%sp%\%~1" (
        MKDIR "%rd%%sp%\%~1"
        XCOPY "%sd%%sp%\%~1" "%rd%%sp%\%~1" /E /T /O /H /R /Q /C
    )
    IF NOT EXIST "%sd%%sp%\%~1.bak" MOVE /Y "%sd%%sp%\%~1" "%sd%%sp%\%~1.bak"
    MKLINK /D "%sd%%sp%\%~1" "%rd%%sp%\%~1" || ECHO Not created: %sd%%sp%\%~1 
    XCOPY "%sd%%sp%\%~1.bak" "%sd%%sp%\%~1" /E /T /O /H /R /Q /C
    RD "%sd%%sp%\%~1.bak" 2>NUL
EXIT /B
)
:ParsePath
(
    SET "sp=%~pnx1"
    SET "sd=%~d1"
EXIT /B
)
REM Dir list
REM ---separator---
Roaming\NVIDIA
Roaming\Microsoft\Windows\Themes\CachedFiles
Local\Temp
Local\Steam
Local\NVIDIA\NvBackend
Local\Dropbox\logs
Local\Google\Chrome\User Data\Profile *\Cache
Local\Google\Chrome\User Data\Profile *\GPUCache
Local\Google\Chrome\User Data\Profile *\Media Cache
Local\Google\Chrome\User Data\Profile *\Service Worker
Local\Google\Chrome\User Data\Profile *\Code Cache
;Local\Google\Chrome\User Data\Profile *\JumpListIcons
;Local\Google\Chrome\User Data\Profile *\JumpListIconsOld
Local\Google\Chrome\User Data\Default\Cache
Local\Google\Chrome\User Data\Default\GPUCache
Local\Google\Chrome\User Data\Default\Media Cache
Local\Google\Chrome\User Data\Default\Service Worker
Local\Google\Chrome\User Data\Default\Code Cache
;Local\Google\Chrome\User Data\Default\JumpListIcons
;Local\Google\Chrome\User Data\Default\JumpListIconsOld
Local\Microsoft\Internet Explorer
Local\Microsoft\Media Player\Transcoded Files Cache
;Local\Microsoft\Windows\Caches
Local\Microsoft\Windows\Explorer
Local\Microsoft\Windows\INetCache
Local\Microsoft\Windows\INetCookies
Local\Microsoft\Windows\Notifications
Local\Microsoft\Windows\WebCache
LocalLow
