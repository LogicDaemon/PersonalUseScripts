@(REM coding:CP866
    IF DEFINED PROCESSOR_ARCHITEW6432 (
        "%SystemRoot%\SysNative\cmd.exe" /C %0 %*
        EXIT /B
    )
    SETLOCAL ENABLEEXTENSIONS
    IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

    IF NOT DEFINED ErrorCmd (
        SET "ErrorCmd=SET ErrorPresence=1"
        SET "ErrorPresence="
    )
    SET "utilsdir=%~dp0..\utils\"
    SET "OS64Bit="
    IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
    IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"
    IF NOT DEFINED exename7za IF DEFINED OS64Bit ( SET "exename7za=7za64.exe" ) ELSE ( SET "exename7za=7za.exe" )
    IF NOT DEFINED exenameAutohotkey IF DEFINED OS64Bit ( SET "exenameAutohotkey=AutoHotkeyU64.exe" ) ELSE ( SET "exenameAutohotkey=AutoHotkeyU32.exe" )
)
(
    IF NOT DEFINED exe7z SET exe7z="%utilsdir%%exename7za%"
    rem IF NOT DEFINED AutohotkeyExe
    rem Even if it's defined, it could be installed without libs which are required
    SET AutohotkeyExe="%utilsdir%%exenameAutohotkey%"
    SET "IsAdmin="
    IF NOT "%~1"=="/user" (
        REM Check if running with admin rights
        %SystemRoot%\System32\fltmc.exe >nul 2>&1 && SET "IsAdmin=1"
    )
    IF NOT DEFINED AhkLibPrimaryDestination (
        IF DEFINED IsAdmin (
            IF EXIST "%ProgramFiles%\AutoHotkey" (
                SET "AhkLibPrimaryDestination=%ProgramFiles%\AutoHotkey\Lib"
            ) ELSE IF EXIST "%ProgramFiles(x86)%\AutoHotkey" (
                SET "AhkLibPrimaryDestination=%ProgramFiles(x86)%\AutoHotkey\Lib"
            )
        )
        IF NOT DEFINED AhkLibPrimaryDestination (
            CALL :GetAhkUserLibDir AhkLibPrimaryDestination
            IF NOT DEFINED AhkLibPrimaryDestination (
                ECHO Error getting user lib dir with an autohotkey script
                SET "AhkLibPrimaryDestination=%USERPROFILE%\Documents\AutoHotkey\Lib"
            )
        )
    )
)
(
    IF NOT EXIST "%AhkLibPrimaryDestination%\*.*" IF EXIST "%AhkLibPrimaryDestination%" (
        RD "%AhkLibPrimaryDestination%"
        MOVE "%AhkLibPrimaryDestination%" "%AhkLibPrimaryDestination%.bak%RANDOM%"
    )
    ECHO n|%exe7z% x -aos -o"%AhkLibPrimaryDestination%" -- "%srcpath%%~n0.7z"||%ErrorCmd%
    IF NOT DEFINED ErrorPresence EXIT /B 0
)
EXIT /B %ErrorPresence%
:GetAhkUserLibDir <var>
(
    FOR /F "usebackq tokens=1 delims=" %%A IN (`"%AutohotkeyExe% "%utilsdir%Get_AutoHotkey_Users_Lib_Dir.ahk""`) DO (
        SET "%~1=%%~A"
        EXIT /B
    )
    EXIT /B 1
)
