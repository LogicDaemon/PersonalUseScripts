@(REM coding:CP866
    IF "%~1"=="" GOTO :usage
    IF "%~1"=="/?" GOTO :usage
    
    SET cleanup=1
    SET compactLZX=1
    SET markDirCompact=
    SET purgeIndexedDB=1
)
:nextArg
(
    IF /I "%~1"=="/purgeCaches" (
        SET cleanup=1
    ) ELSE IF /I "%~1"=="/keepCaches" (
        SET cleanup=
    ) ELSE IF /I "%~1"=="/keepIndexedDB" (
        SET purgeIndexedDB=
    ) ELSE IF /I "%~1"=="/purgeIndexedDB" (
        SET purgeIndexedDB=1
    ) ELSE IF /I "%~1"=="/skipLZX" (
        SET compactLZX=
    ) ELSE IF /I "%~1"=="/markDirCompact" (
        SET markDirCompact=1
    ) ELSE IF /I "%~1"=="/chrome" (
        CALL :CleanProfilesIn "%LocalAppData%\Google\Chrome*"
    ) ELSE IF /I "%~1"=="/vivaldi" (
        CALL :CleanProfilesIn "%LocalAppData%\Vivaldi*"
    ) ELSE (
        CALL :CleanProfilesIn %1
    )
    IF "%~2"=="" (
        IF NOT DEFINED LastCleanupMask GOTO :usage
        EXIT /B
    )
    SHIFT
    GOTO :nextArg
)
ECHO Shouldn't be here
PAUSE
EXIT /B 1
:CleanProfilesIn <path>
(
    SET "LastCleanupMask=%~1"
    FOR /D %%B IN (%1) DO @IF EXIST "%%~B\." (
        IF "%compactLZX%"=="1" COMPACT /C /S:"%%~B\Application" /F /EXE:LZX
        FOR /D %%P IN ("%%~B\User Data\*") DO @IF EXIST "%%~P\Preferences" (
            SET "LastProfileFound=%%~P"
            FOR /D %%C IN ("%%~P" "%%~P\Storage\ext\*") DO @(
                ECHO Cleaning up %%C
                REM + "File System"
                IF "%purgeIndexedDB%"=="1" RD /S /Q "%%~C\IndexedDB"
                IF "%cleanup%"=="1" (
                    FOR /D %%D IN ("Application Cache" "Cache" "Code Cache" "GPUCache" "Service Worker" "def\Application Cache" "def\Cache" "def\Code Cache" "def\GPUCache") DO @(
                        IF EXIST "%%~C\%%~D\." RD /S /Q "%%~C\%%~D"
                    )
                    FOR /D %%D IN ("%%~C\old_*") DO RD /S /Q "%%~C\%%~D"
                )
            )
            IF "%compactLZX%"=="1" COMPACT /Q /C /S:"%%~P\Extensions" /F /EXE:LZX
        )
        IF "%markDirCompact%"=="1" COMPACT /Q /C /S:"%%~B"
    )
    EXIT /B
)
:usage
@(
    ECHO %0 [/skipCompaction] [/chrome] [/vivaldi] [path [path [...]]]
    ECHO.
    ECHO Mode switches only apply to profile-switches and paths appearing after them on command line
    ECHO                        * below means default
    ECHO /purgeCaches           * purge caches
    ECHO /keepCaches              don't purge caches
    ECHO /keepIndexedDB         * keep Chrome\User Data\profile\IndexedDB
    ECHO /purgeIndexedDB          remove Chrome\User Data\profile\IndexedDB. Only works when purging caches.
    ECHO /skipLZX                 don't call COMPACT /EXE:LZX for program files, extensions and cache files if not purged. LZX appeared in Windows 10 NTFS.
    ECHO /markDirCompact          call COMPACT for remaining files and directories with default method, so new files will also get autocompacted
    ECHO.
    ECHO Locations to look profiles in:
    ECHO /chrome                  %%LocalAppData%%\Google\Chrome*
    ECHO /vivaldi                 %%LocalAppData%%\Vivaldi*
    ECHO path                     specified explicitly
    EXIT /B
)
