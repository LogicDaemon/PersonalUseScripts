@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
    SET "destDir=%~d0\Games\FAF Client versions"
    SET "latestVerLinkPath=%~d0\Games\FAF Client"
    CALL find7zexe.cmd || EXIT /B
)
@(
    CALL :cleanup
    FOR /F "usebackq delims=" %%A IN (`DIR /B /A-D /O-D "faf_windows-x64_*.zip"`) DO @(
        %exe7z% x -o"%destDir%\temp" -- "%%~A" || EXIT /B
        FOR /D %%B IN ("%destDir%\temp\*.*") DO @(
            IF EXIST "%destDir%\%%~nxB" (
                ECHO Version %%~nxB exists in "%destDir%\%%~nxB", not replacing contents
                SET "nocleanup=1"
            ) ELSE (
                MOVE /Y "%%~B" "%destDir%\%%~nxB"
            )
            ECHO Updating the link to version %%~nxB
            IF EXIST "%latestVerLinkPath%" RD "%latestVerLinkPath%" || ECHO N|DEL "%latestVerLinkPath%"
            MKLINK /D "%latestVerLinkPath%" "%destDir%\%%~nxB" || MKLINK /J "%latestVerLinkPath%" "%destDir%\%%~nxB"
            EXIT /B
        )
    )
)
:cleanup
@(
    IF NOT DEFINED nocleanup RD /S /Q "%destDir%\temp"
EXIT /B
)
