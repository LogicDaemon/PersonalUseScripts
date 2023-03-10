@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "%~dp0*.7z"`) DO (
        SET "latest=%%~A"
        GOTO :found
    )
    ECHO Found no matching distributive.
EXIT /B 1
)
:found
@(
    CALL find7zexe.cmd x -aoa -y -o"%LOCALAPPDATA%\Programs\vlc.tmp" -- "%latest%" || EXIT /B
    FOR /D %%A IN ("%LOCALAPPDATA%\Programs\vlc.tmp\*.*") DO (
        MOVE "%%~A" "%LOCALAPPDATA%\Programs\%%~nxA"
        REM should only be one directory inside
        RD /Q "%LOCALAPPDATA%\Programs\vlc.tmp" || EXIT /B
        MKLINK /J "%LOCALAPPDATA%\Programs\vlc.tmp" "%LOCALAPPDATA%\Programs\%%~nxA"
    )
    IF NOT EXIST "%LOCALAPPDATA%\Programs\vlc.tmp" EXIT /B
    IF EXIST "%LOCALAPPDATA%\Programs\vlc" RD "%LOCALAPPDATA%\Programs\vlc" || EXIT /B
    REN "%LOCALAPPDATA%\Programs\vlc.tmp" "vlc"
)
