@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-N "%~dp0"`) DO (
        IF EXIST "%~dp0%%~A\AOMEIBackupperStd.exe" (
            MKLINK /H "%TEMP%\AOMEIBackupperStd.exe" "%~dp0%%~A\AOMEIBackupperStd.exe" || MKLINK "%TEMP%\AOMEIBackupperStd.exe" "%~dp0%%~A\AOMEIBackupperStd.exe" || COPY "%~dp0%%~A\AOMEIBackupperStd.exe" "%TEMP%\AOMEIBackupperStd.exe"
            START "" /B /D "%TEMP%" "%TEMP%\AOMEIBackupperStd.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- || CALL :RememberError
            DEL "%TEMP%\AOMEIBackupperStd.exe"
            IF DEFINED InstallError GOTO :ExitWithError
            EXIT /B
        )
    )
    EXIT /B 1
)
:RememberError
(
    SET "InstallError=%ERRORLEVEL%"
    EXIT /B
)
:ExitWithError
EXIT /B %InstallError%
