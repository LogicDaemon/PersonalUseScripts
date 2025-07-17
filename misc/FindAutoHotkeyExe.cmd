@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF EXIST "%LOCALAPPDATA%\Programs\bin\ahk.exe" (
        CALL "%LOCALAPPDATA%\Programs\bin\ahk.exe" /ErrorStdOut "%~dp0FindAutoHotkeyExe_CheckVer.ahk" && SET AutohotkeyExe="%LOCALAPPDATA%\Programs\bin\ahk.exe"
    ) ELSE IF DEFINED AutohotkeyExe (
        IF EXIST %AutohotkeyExe% CALL %AutohotkeyExe% /ErrorStdOut "%~dp0FindAutoHotkeyExe_CheckVer.ahk" || SET AutohotkeyExe=
        IF NOT DEFINED AutohotkeyExe (
            ECHO Checking AutoHotkeyScript type>&2
            FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO @CALL :CheckAutohotkeyExe %%I
            rem continuing if AutoHotkeyScript type isn't defined or specified path points to incorect location
            IF NOT DEFINED AutohotkeyExe CALL :FindAutohotkeyExeViaFindExe
        )
    )
    IF NOT DEFINED AutohotkeyExe (
        ECHO AutoHotkey executable not found.>&2
        EXIT /B 9009
    )
    IF "%~1"=="" EXIT /B 0
)
(
    ECHO Starting "%~1" with "%AutohotkeyExe%">&2
    %AutohotkeyExe% %*
    @EXIT /B
)
:FindAutohotkeyExeViaFindExe
@(
    IF NOT DEFIEND OS64bit (
        SET "OS64bit="
        IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( SET "OS64bit=1"
        ) ELSE IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" ( SET "OS64bit=1"
        ) ELSE IF DEFINED ProgramFiles^(x86^) ( SET "OS64bit=1"
        )
    )

    SET "ahkExeAddNames="
    IF DEFINED OS64bit (
        SET "ahkExeAddNames=AutoHotkeyU64.exe ahk64.exe"
    )
)
@(
    FOR %%A IN (%ahkExeAddNames% AutoHotkey.exe AutoHotkeyU32.exe ahk.exe) DO @(
        CALL :CheckAutohotkeyExe "%LOCALAPPDATA%\Programs\AutoHotkey\%%A" && EXIT /B
        CALL :CheckAutohotkeyExe "%LOCALAPPDATA%\Programs\%%A" && EXIT /B
        CALL :CheckAutohotkeyExe "%LOCALAPPDATA%\Programs\bin\%%A" && EXIT /B
        CALL :CheckAutohotkeyExe "%ProgramFiles%\AutoHotkey\%%A" && EXIT /B
        IF DEFINED OS64bit CALL :CheckAutohotkeyExe "%ProgramFiles(x86)%\AutoHotkey\%%A" && EXIT /B
    )
    CALL :tryutilsdir && EXIT /B
    
    REM without these options, autohotkey.exe starts AutoHotkey.ahk, opens help or says
    rem 	Script file not found:
    rem 	D:\Users\*\Documents\AutoHotkey.ahk
    IF EXIST "%~dp0FindAutoHotkeyExe_CheckVer.ahk" (
        SET "findExeTestExecutionOptions=/ErrorStdOut "%~dp0FindAutoHotkeyExe_CheckVer.ahk" 9009"
        CALL "%~dp0find_exe.cmd" AutohotkeyExe AutoHotkey.exe
        IF ERRORLEVEL 9009 IF DEFINED OS64bit CALL "%~dp0find_exe.cmd" AutohotkeyExe AutoHotkeyU64.exe
        IF ERRORLEVEL 9009 CALL "%~dp0find_exe.cmd" AutohotkeyExe AutoHotkeyU32.exe
    )

    REM explicit backup not needed in same parethensis scope
    SET "findExeTestExecutionOptions=%findExeTestExecutionOptions%"
    EXIT /B
)
:tryutilsdir
@IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd" || EXIT /B 1
@(
    (CALL :CheckAutohotkeyExe "%utilsdir%AutoHotkey.exe" || CALL :CheckAutohotkeyExe "%utilsdir%ahk.exe") && EXIT /B
    IF DEFINED OS64bit (CALL :CheckAutohotkeyExe "%utilsdir%AutoHotkeyU64.exe" && EXIT /B)
    CALL :CheckAutohotkeyExe "%utilsdir%AutoHotkeyU32.exe" && EXIT /B
EXIT /B
)
:CheckAutohotkeyExe <path>
@(
    IF NOT EXIST %1 EXIT /B 1
    ECHO Checking "%~1">&2
    CALL %1 /ErrorStdOut "%~dp0FindAutoHotkeyExe_CheckVer.ahk" || EXIT /B
    ECHO Found a matching autohotkey: "%~1">&2
    SET "AutohotkeyExe=%1"
    SET "AutohotkeyUnquotedExe=%~1"
)
@(
    IF "%AutohotkeyUnquotedExe:~0,2%"=="\\" (
        MKDIR "%LOCALAPPDATA%\Programs\AutoHotkey"
        %SystemRoot%\System32\icacls.exe "%LOCALAPPDATA%\Programs\AutoHotkey" /grant "*S-1-1-0:(OI)(CI)RX"
        COPY /B %1 "%LOCALAPPDATA%\Programs\AutoHotkey\%~nx1"
        SET AutohotkeyExe="%LOCALAPPDATA%\Programs\AutoHotkey\%~nx1"
        IF EXIST "%~dp1Lib\*.*" (
            MKDIR "%LOCALAPPDATA%\Programs\AutoHotkey\Lib"
            XCOPY "%~dp1Lib\*.*" "%LOCALAPPDATA%\Programs\AutoHotkey\Lib\" /E /C /I /Q /H /R /Y
        )
        IF EXIST "%~dp1..\auto\AutoHotkey_Lib.7z" CALL :Unpack "%~dp1..\auto\AutoHotkey_Lib.7z" "%LOCALAPPDATA%\Programs\AutoHotkey\Lib"
    )
    EXIT /B 0
)
:Unpack <arch> <dest>
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd"
(
    %exe7z% x -aoa -y -o%2 -- %1
    EXIT /B
)
