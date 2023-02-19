@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    SET "RAMDrive=r:"
    IF EXIST "%LocalAppData%\Programs\bin\xln.exe" SET xlnexe="%LocalAppData%\Programs\bin\xln.exe"
)
@(
    IF NOT EXIST "%RAMDrive%\" EXIT /B
    ATTRIB +I "%RAMDrive%\*.*" /S /D /L
    
    FOR %%B IN ("%LOCALAPPDATA%\Google\Chrome" "%LOCALAPPDATA%\Google\Chrome Beta" "%LOCALAPPDATA%\Chromium" "%LOCALAPPDATA%\Vivaldi") DO @(
        FOR /D %%P IN ("%%~B\User Data\Default" "%%~B\User Data\Profile *") DO @(
            FOR /D %%E IN ("%%~P" "%%~P\Storage\ext\*") DO (
                FOR /F "usebackq delims=" %%A IN ("%~dp0Chrome_Profile_Temporary.txt") DO IF EXIST "%%~E\%%~A" CALL :MoveToRAMDrive "%%~E\%%~A"
            )
        )
    )
    CALL :CopyPermissions "%USERPROFILE%"
    EXIT /B
)
:MoveToRAMDrive <src_path> <dest_drive>
(
    IF "%~2"=="" ( CALL :LinkBack %1 "%RAMDrive%%~pnx1" ) ELSE ( CALL :LinkBack %1 "%~2%~pnx1" )
EXIT /B
)
:CopyPermissions <src_path> <dest_drive>
(
    IF "%~2"=="" ( XCOPY %1 "%RAMDrive%%~pnx1" /Y /T /E /O /U /K /B ) ELSE ( XCOPY %1 "%~2%~pnx1" /Y /T /E /O /U /K /B )
EXIT /B
)
:LinkBack <source> <destination>
(
    IF EXIST "%~1\*" IF NOT EXIST %2 (
	IF NOT EXIST "%~dp2" MKDIR "%~dp2"
	IF NOT EXIST "%~dp2" EXIT /B
	MOVE /Y %1 %2
    )
    IF NOT EXIST %2 MKDIR %2
    IF NOT EXIST %2 EXIT /B
    RD /Q %1
    MKLINK /D %1 %2 || MKLINK /J %1 %2 || IF DEFINED xlnexe (
        %xlnexe% -n %2 %1 || (
            RD /S /Q %1
            xln.exe -n %2 %1
        )
    )
EXIT /B
)
