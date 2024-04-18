@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

REM usage: _Distributives.find_subpath.cmd varname subpath
SETLOCAL ENABLEEXTENSIONS
    FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO @SET "hostname=%%~J"
    SET "baseDirsListFile=%~dp0_Distributives.base_dirs.txt"
    SET "subPath=%~2"
    IF NOT DEFINED subPath SET "subPath=Soft"
    SET found=
)
@IF EXIST "%~dp0_Distributives.base_dirs@%hostname%.txt" SET "baseDirsListFile=%~dp0_Distributives.base_dirs@%hostname%.txt"
@(
    FOR /F "usebackq delims=" %%A IN ("%baseDirsListFile%") DO @(
        IF EXIST "%%~A\%subPath%" (
            SET "found=%%~A"
            GOTO :found
        )
        IF EXIST "%%~A\Distributives\%subPath%" (
            SET "found=%%~A\Distributives"
            GOTO :found
        )
    )
    EXIT /B 1
)
:found
@(
    ECHO %found%
    ENDLOCAL
    IF "%~1"=="" EXIT /B
    SET "%~1=%found%"
    EXIT /B
)
