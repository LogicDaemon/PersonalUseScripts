@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
    IF DEFINED ahk2exe (
        IF EXIST %ahk2exe% CALL %ahk2exe% /ErrorStdOut "%~dp0find_ahk2exe_CheckVer.ahk2" || SET ahk2exe=
        IF NOT DEFINED ahk2exe (
            FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkey2Script`) DO @CALL :Checkahk2exe %%I
            rem continuing if AutoHotkeyScript type isn't defined or specified path points to incorect location
            IF NOT DEFINED ahk2exe CALL :Findahk2exeViaFindExe
        )
    )
    IF NOT DEFINED ahk2exe EXIT /B 9009
    IF "%~1"=="" EXIT /B 0
)
(
    %ahk2exe% %*
    @EXIT /B
)
:Findahk2exeViaFindExe
@(
    IF NOT DEFIEND OS64bit (
        SET "OS64bit="
        IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( SET "OS64bit=1"
        ) ELSE IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" ( SET "OS64bit=1"
        ) ELSE IF DEFINED ProgramFiles^(x86^) ( SET "OS64bit=1"
        )
    )

    SET "ahkExeAddNames="
    IF DEFINED OS64bit SET "ahkExeAddNames=AutoHotkey64.exe"
)
@(
    FOR %%A IN (%ahkExeAddNames% AutoHotkey32.exe) DO @(
        CALL :Checkahk2exe "%LOCALAPPDATA%\Programs\AutoHotkey_v2\%%A" && EXIT /B
        CALL :Checkahk2exe "%LOCALAPPDATA%\Programs\AutoHotkey\v2\%%A" && EXIT /B
        CALL :Checkahk2exe "%LOCALAPPDATA%\Programs\%%A" && EXIT /B
        CALL :Checkahk2exe "%LOCALAPPDATA%\Programs\bin\%%A" && EXIT /B
        CALL :Checkahk2exe "%ProgramFiles%\AutoHotkey\v2\%%A" && EXIT /B
        CALL :Checkahk2exe "%ProgramFiles%\AutoHotkey\%%A" && EXIT /B
        IF DEFINED OS64bit CALL :Checkahk2exe "%ProgramFiles(x86)%\AutoHotkey\v2\%%A" && EXIT /B
        IF DEFINED OS64bit CALL :Checkahk2exe "%ProgramFiles(x86)%\AutoHotkey\%%A" && EXIT /B
    )
    CALL :tryutilsdir && EXIT /B
    
    IF EXIST "%~dp0find_ahk2exe_CheckVer.ahk2" (
        SET "findExeTestExecutionOptions=/ErrorStdOut "%~dp0find_ahk2exe_CheckVer.ahk2" 9009"
        CALL "%~dp0find_exe.cmd" ahk2exe %ahkExeAddNames% AutoHotkey32.exe
    )

    REM explicit backup not needed in the same parethensis scope
    SET "findExeTestExecutionOptions=%findExeTestExecutionOptions%"
    EXIT /B
)
:tryutilsdir
@IF NOT DEFINED utilsdir CALL "%~dp0FindSoftwareSource.cmd" || EXIT /B 1
@(
    IF DEFINED OS64bit CALL :Checkahk2exe "%utilsdir%AutoHotkey64.exe" && EXIT /B
    CALL :Checkahk2exe "%utilsdir%AutoHotkey32.exe"
EXIT /B
)
:Checkahk2exe <path>
@(
    IF NOT EXIST %1 EXIT /B 1
    CALL %1 /ErrorStdOut "%~dp0find_ahk2exe_CheckVer.ahk2" || EXIT /B
    SET "ahk2exe=%1"
    SET "AutohotkeyUnquotedExe=%~1"
)
@(
    IF "%AutohotkeyUnquotedExe:~0,2%"=="\\" (
        MKDIR "%LOCALAPPDATA%\Programs\AutoHotkey_v2"
        %SystemRoot%\System32\icacls.exe "%LOCALAPPDATA%\Programs\AutoHotkey_v2" /grant "*S-1-1-0:(OI)(CI)RX"
        COPY /B %1 "%LOCALAPPDATA%\Programs\AutoHotkey_v2\%~nx1"
        SET ahk2exe="%LOCALAPPDATA%\Programs\AutoHotkey_v2\%~nx1"
        IF EXIST "%~dp1Lib\*.*" (
            MKDIR "%LOCALAPPDATA%\Programs\AutoHotkey_v2\Lib"
            XCOPY "%~dp1Lib\*.*" "%LOCALAPPDATA%\Programs\AutoHotkey_v2\Lib\" /E /C /I /Q /H /R /Y
        )
        IF EXIST "%~dp1..\auto\AutoHotkey2_Lib.7z" CALL :Unpack "%~dp1..\auto\AutoHotkey2_Lib.7z" "%LOCALAPPDATA%\Programs\AutoHotkey_v2\Lib"
    )
    EXIT /B 0
)
:Unpack <arch> <dest>
IF NOT DEFINED exe7z CALL "%~dp0find7zexe.cmd"
(
    %exe7z% x -aoa -y -o%2 -- %1
    EXIT /B
)
