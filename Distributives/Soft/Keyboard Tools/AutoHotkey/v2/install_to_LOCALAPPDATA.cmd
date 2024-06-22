@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~1"=="" (
        SET "OSWordSize=32"
        IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSWordSize=64"
        IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSWordSize=64"
    ) ELSE (
        SET "OSWordSize=%~1"
    )
    CALL find7zexe.cmd
    IF NOT DEFINED exe7z SET exe7z="%~dp0..\..\PreInstalled\utils\7za%OSWordSize%.exe"
    
    SET "staticDestLink=%LOCALAPPDATA%\Programs\AutoHotkey_v2"
    SET "versionedDestDirPrefix=%LOCALAPPDATA%\Programs\AutoHotkey_v2"
)
@(
    IF "%OSWordSize%"=="64" (
        SET "add7zArgs=%add7zArgs% -x!AutoHotkey32.exe"
    ) ELSE IF "%OSWordSize%"=="32" (
        SET "add7zArgs=%add7zArgs% -x!AutoHotkey64.exe"
    )
    IF NOT DEFINED exenameahk SET "exenameahk=AutoHotkey%OSWordSize%.exe"
    FOR /F "usebackq tokens=1*" %%A IN ("%~dp0ver.zip.txt") DO (
        ECHO %%A %%B
        SET "ahkVer=%%~A"
        SET "distributiveArchivePath=%%~B"
        SET "versionedDestDir=%versionedDestDirPrefix%-%%~A"
    )
)
(
    %exe7z% x -aoa -y -o"%versionedDestDir%" %add7zArgs% -- "%~dp0%distributiveArchivePath%" || CALL :SaveExitErrorCode
    START "Compacting rarely used Autohotkey files" /MIN /LOW COMPACT /C /EXE:LZX /S:"%versionedDestDir%\UX" *.*
    START "Compacting rarely used Autohotkey files" /MIN /LOW COMPACT /C /EXE:LZX "%versionedDestDir%\*.ahk" "%versionedDestDir%\*.txt"
    IF NOT DEFINED ExitErrorCode (
        IF EXIST "%staticDestLink%" RD "%staticDestLink%"
        MKLINK /J "%staticDestLink%" "%versionedDestDir%" || CALL :SaveExitErrorCode
        rem "%staticDestLink%\%exenameahk%" "%~dp0associate.ahk" /user
        EXIT /B
    )
)
EXIT /B %ExitErrorCode%
:SaveExitErrorCode
(
    SET "ExitErrorCode=%ERRORLEVEL%"
EXIT /B
)
