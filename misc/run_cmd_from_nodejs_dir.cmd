@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
SETLOCAL ENABLEEXTENSIONS
SET "nodeBasePath=%LOCALAPPDATA%\Programs\nodejs"
)
@(
    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-D "%nodeBasePath%\node-*-win-x64"`) DO @(
        SET "PATH=%PATH%;%nodeBasePath%\%%~A"
        IF "%~x1"==".cmd" (
            CALL "%nodeBasePath%\%%~A"\%*
        ) ELSE "%nodeBasePath%\%%~A"\%*
        EXIT /B
    )

    ECHO node not found!
    ECHO Download it and unarchive to "%nodeBasePath%"
    START "" https://nodejs.org/en/download/current/
    EXIT /B -1
)
