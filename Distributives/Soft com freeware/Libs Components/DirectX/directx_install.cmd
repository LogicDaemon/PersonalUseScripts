@REM coding:OEM
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF "%RunInteractiveInstalls%"=="0" (
    SET LogOffAfterInstall=0
    SET RebootAfterInstall=0
)

IF NOT DEFINED ActionAfterInstall IF NOT DEFINED LogOffAfterInstall IF NOT DEFINED LogOffAfterInstall (
    SET /P ActionAfterInstall=После установки: 1 - перезагрузка, 2 - завершить сеанс, остальное - ничего: 
)
IF "%ActionAfterInstall%"=="1" SET RebootAfterInstall=1
IF "%ActionAfterInstall%"=="2" SET LogOffAfterInstall=1

IF NOT DEFINED ErrorCmd (
    IF NOT "%RunInteractiveInstalls%"=="0" (
        SET ErrorCmd=ECHO &SET ErrorPresence==1
    ) ELSE (
        SET ErrorCmd=IF ERRORLEVEL 2 EXIT /B 2
    )
)

IF NOT "%1"=="" (
    SET DXDistributiveFile=%1
    SET DXTempDir=%Temp%\~n1\
    GOTO :skipfindDXDistributiveFile
)

IF NOT DEFINED DXDistributiveFile SET DXDistributiveFile=%srcpath%directx_*_redist.exe
FOR %%I IN ("%DXDistributiveFile%") DO SET DXDistributiveFile=%%I

IF NOT DEFINED DXTempDir SET DXTempDir=%Temp%\DirectX\

:skipfindDXDistributiveFile
7za x -aoa "%DXDistributiveFile%" -o"%DXTempDir%"||%ErrorCmd%
"%DXTempDir%DXSETUP.exe" /SILENT||%ErrorCmd%

RD /s /q "%DXTempDir%"||%ErrorCmd%
IF "%RunInteractiveInstalls%"=="1" IF "%ErrorPresence%"=="1" (
    tail "%SystemRoot%\logs\DirectX.log"
    IF EXIST "%SystemRoot%\logs\DXError.log" notepad "%SystemRoot%\logs\DXError.log"
)

IF "%LogOffAfterInstall%"=="1" LOGOFF /V
IF "%RebootAfterInstall%"=="1" shutdown -r -t 0
REM TODO: Install ACT! on Windows 2K
