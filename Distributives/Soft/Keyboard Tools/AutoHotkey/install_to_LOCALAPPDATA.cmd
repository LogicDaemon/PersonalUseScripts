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
)
IF "%OSWordSize%"=="64" (
    SET "exenameahk=AutoHotkeyU64.exe"
    IF NOT DEFINED exe7z SET "exe7z=%~dp0..\..\PreInstalled\utils\7za64.exe"
) ELSE (
    SET "exenameahk=AutoHotkey.exe"
    IF NOT DEFINED exe7z SET "exe7z=%~dp0..\..\PreInstalled\utils\7za.exe"
)
(
    FOR /F "usebackq delims=" %%A IN (`DIR /O-D /B "%~dp0AutoHotkey_*.zip"`) DO @(
        CALL find7zexe.cmd x -aoa -y -o"%LOCALAPPDATA%\Programs\%%~nA" "%~dp0%%~A"
        MKLINK /D "%LOCALAPPDATA%\Programs\AutoHotkey" "%LOCALAPPDATA%\Programs\%%~nA" || MKLINK /J "%LOCALAPPDATA%\Programs\AutoHotkey" "%LOCALAPPDATA%\Programs\%%~nA" || (
            RD "%LOCALAPPDATA%\Programs\AutoHotkey" && (
                MKLINK /D "%LOCALAPPDATA%\Programs\AutoHotkey" "%LOCALAPPDATA%\Programs\%%~nA" || MKLINK /J "%LOCALAPPDATA%\Programs\AutoHotkey" "%LOCALAPPDATA%\Programs\%%~nA"
            )
        )
        IF NOT EXIST "%LocalAppData%\Programs\bin\ahk.exe" (
            IF NOT EXIST "%LocalAppData%\Programs\bin" MKDIR "%LocalAppData%\Programs\bin"
            MKLINK "%LocalAppData%\Programs\bin\ahk.exe" "%LOCALAPPDATA%\Programs\AutoHotkey\%exenameahk%"
        )
        CALL "%~dp0..\..\PreInstalled\auto\AutoHotkey_Lib.cmd"
        "%LOCALAPPDATA%\Programs\AutoHotkey\%exenameahk%" "%~dp0associate.ahk" /user
        EXIT /B
    )
)
