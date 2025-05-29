@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
    
    SET "distSubdir=Developement\Amazon\AWSCLIV2"
)
SET "lastInstLogDir=%LOCALAPPDATA%\LogicDaemon\Distributives\%distSubdir%"
SET "lastInstLogPath=%lastInstLogDir%\lastInstalled.txt"
@(
    IF NOT EXIST "%lastInstLogPath%" (
        aws.exe || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
        MKDIR "%lastInstLogDir%"
    )
    CALL "%~dp0_Distributives.find_subpath.cmd" Distributives "%distSubdir%\install.cmd"
    FOR /F "usebackq delims=" %%A IN ("%lastInstLogPath%") DO @(
        SET "lastInstalled=%%~A"
        GOTO :break
    )
)
:break
@(
    CALL "%Distributives%\%distSubdir%\.Distributives_Update_Run.All.cmd"
    
    FOR /F %%A IN ("%Distributives%\%distSubdir%\AWSCLIV2.msi") DO SET "newDistributiveDateTime=%%~tA"
    IF "%lastInstalled%"=="%newDistributiveDateTime%" (
        ECHO The current distributive is already installed
    )
)
@(
    (
        ECHO %newDistributiveDateTime%
        CALL "%distributives%\%distSubdir%\install.cmd" 2>&1
    ) >"%lastInstLogPath%.tmp"
    IF ERRORLEVEL 1 (
        TYPE "%lastInstLogPath%.tmp"
    ) ELSE (
        MOVE /Y "%lastInstLogPath%.tmp" "%lastInstLogPath%"
    )
)
