@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

    CALL "%~dp07z_get_switches.cmd"
    CALL find7zexe.cmd || SET exe7z="%~dp0..\bin\7zG.exe"

    SET "tmpDir=%TEMP%\PreInstalled-tc-new"
    SET "bakDir=%TEMP%\PreInstalled-tc-backup"

    PUSHD "%~dp0\..\PlugIns\wdx\TrID_Identifier\TrID" && (
        CALL update.cmd
        POPD
    )

    REM SET "dstDir=d:\Distributives\Soft\PreInstalled\manual"
    CALL _Distributives.find_subpath.cmd distBaseDir Soft\PreInstalled\manual
)
@SET "dstDir=%distBaseDir%\Soft\PreInstalled\manual"
PUSHD "%srcpath%\.." && (
    MKDIR "%tmpDir%"

    REM 0. dont pack -  %~n0.exclude-list.txt
    SET excludes=-x@"%~dpn0.exclude.txt"

    CALL :PackAddExcl DBs

    @REM "%~dp0..\bin\AutoHotkey.exe" "%APPDATA%\notepad2\CleanupNotepad2Ini.ahk" "%APPDATA%\notepad2\notepad2.ini"
    CALL :PackAddExcl config
    @REM MOVE /Y "%APPDATA%\notepad2\notepad2.ini.bak" "%APPDATA%\notepad2\notepad2.ini"

    CALL :PackAddExcl plugins64bit
    CALL :PackAddExcl plugins
    CALL :PackAddExcl 64bit
    CALL :PackAddExcl 32bit
    @REM new block to let %excludes% update
)
(
    @REM everything else without all previous
    %exe7z% u -uq0 -r %z7zswitchesLZMA2BCJ2% %excludes% -- "%tmpDir%\TotalCommander.7z"

    MKDIR "%bakDir%"
    FOR %%A IN ("%tmpDir%\*.*") DO IF %%~zA GTR 32 FC /B /LB1 /A "%%~A" "%dstDir%\%%~nxA" > NUL || (
        MOVE /Y "%dstDir%\%%~nxA" "%bakDir%\%%~nxA" & MOVE "%%~A" "%dstDir%\%%~nxA"
    )
    RD "%tmpDir%"
EXIT /B
)

:PackAddExcl <listName>
(
    %exe7z% u -uq0 -r %z7zswitchesLZMA2BCJ2% %excludes% -i@"%~dpn0.%~1.txt" -- "%tmpDir%\TotalCommander.%~1.7z"
    SET excludes=%excludes% -x@"%~dpn0.%~1.txt"
EXIT /B
)
