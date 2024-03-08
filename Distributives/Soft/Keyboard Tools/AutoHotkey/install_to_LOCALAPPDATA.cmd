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
)
@(
    IF "%OSWordSize%"=="64" (
        SET "add7zArgs=%add7zArgs% -x!AutoHotkeyA32.exe -x!AutoHotkeyU32.exe"
    ) ELSE IF "%OSWordSize%"=="32" (
        SET "add7zArgs=%add7zArgs% -x!AutoHotkeyA32.exe -x!AutoHotkeyU64.exe"
    ) ELSE (
        SET "add7zArgs=%add7zArgs% -x!AutoHotkeyA32.exe"
    )
    IF NOT DEFINED exenameahk SET "exenameahk=AutoHotkeyU%OSWordSize%.exe"
    IF NOT DEFINED exe7z SET exe7z="%~dp0..\..\PreInstalled\utils\7za%OSWordSize%.exe"
    FOR /F "usebackq tokens=1*" %%A IN ("%~dp0ver.zip.txt") DO (
        ECHO %%A %%B
        SET "ahkVer=%%~A"
        SET "ahkDistFilename=%%~B"
        SET "ahkDestDir=%LOCALAPPDATA%\Programs\AutoHotkey %%~A"
    )
)
(
    %exe7z% x -aoa -y -o"%ahkDestDir%" %add7zArgs% -- "%~dp0%ahkDistFilename%" || CALL :SaveExitErrorCode
    START "Compatcing rarely used Autohotkey files" /MIN /LOW COMPACT /C /EXE:LZX "%ahkDestDir%\*.ahk" "%ahkDestDir%\*.txt" "%ahkDestDir%\Compiler\*.*"
    SET "AhkLibPrimaryDestination=%ahkDestDir%\Lib"
    CALL "%~dp0..\..\PreInstalled\auto\AutoHotkey_Lib.cmd" || CALL :SaveExitErrorCode
    IF NOT DEFINED ExitErrorCode (
        IF EXIST "%LOCALAPPDATA%\Programs\AutoHotkey" RD "%LOCALAPPDATA%\Programs\AutoHotkey"
        MKLINK /J "%LOCALAPPDATA%\Programs\AutoHotkey" "%ahkDestDir%" || CALL :SaveExitErrorCode
        IF NOT EXIST "%LocalAppData%\Programs\bin\ahk.exe" (
            IF NOT EXIST "%LocalAppData%\Programs\bin" MKDIR "%LocalAppData%\Programs\bin"
            MKLINK "%LocalAppData%\Programs\bin\ahk.exe" "%LOCALAPPDATA%\Programs\AutoHotkey\%exenameahk%"
        )
        "%LOCALAPPDATA%\Programs\AutoHotkey\%exenameahk%" "%~dp0associate.ahk" /user
        EXIT /B
    )
)
EXIT /B %ExitErrorCode%
:SaveExitErrorCode
(
    SET "ExitErrorCode=%ERRORLEVEL%"
EXIT /B
)
