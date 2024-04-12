@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

    IF NOT EXIST "%USERPROFILE%\Documents\git\hooks" (
        ECHO Add the hook scripts to "%USERPROFILE%\Documents\git\hooks"
        EXIT /B 1
    )
    PUSHD .
)
:CheckDirGitRoot
@(
    SET "lastDir=%CD%"
    IF EXIST .git\hooks\*.* GOTO :FoundRepositoryRoot
    CD ..
)
@(
    IF "%CD%"=="%lastDir%" (
        ECHO Execute from a git repository
        POPD
        EXIT /B 1
    )
    GOTO :CheckDirGitRoot
)
:FoundRepositoryRoot
@(
    COPY /B /L "%USERPROFILE%\Documents\git\hooks\*.*" .git\hooks\
    POPD
)
