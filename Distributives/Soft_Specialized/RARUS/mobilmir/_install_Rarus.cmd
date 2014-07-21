@REM coding:OEM
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

IF EXIST "d:\Distributives\Soft\PreInstalled\utils\" (
    SET utilsdir=d:\Distributives\Soft\PreInstalled\utils\
) ELSE (
    SET utilsdir=\\Srv0\Distributives\Soft\PreInstalled\utils\
)

IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%

SET prog1sDir=%ProgramFiles%\1Cv77
SET commonRarusDir=D:\1S\Rarus
SET rarusConfigbaseDir=%commonRarusDir%\ShopBTS
SET ShopBTS_InitialBase_archive=ShopBTS_InitialBase*.7z

START "" "%~dp0AskOpenLicenses.ahk"

ECHO ON

MKDIR "%ProgramData%\mobilmir.ru"
IF NOT DEFINED ProgramData SET ProgramData=%ALLUSERSPROFILE%\Application Data
IF EXIST "%SystemDrive%\Local_Scripts" (
    MOVE /Y "%SystemDrive%\Local_Scripts\*" "%ProgramData%\mobilmir.ru\"
    FOR /D %%I IN ("%SystemDrive%\Local_Scripts\*") DO MOVE /Y "%%~I" "%ProgramData%\mobilmir.ru\%%~nxI"
    MOVE /Y "%SystemDrive%\Local_Scripts" "%ProgramData%\mobilmir.ru"
    "%SystemDrive%\SysUtils\xln.exe" -n "%ProgramData%\mobilmir.ru" "%SystemDrive%\Local_Scripts"
)
PUSHD "%ProgramData%\mobilmir.ru"||(PAUSE&EXIT /b)
    CALL :unpack "%srcpath%Rarus_Scripts.7z"
POPD

MKDIR "%prog1sDir%\BIN"
PUSHD "%prog1sDir%\BIN"||(PAUSE&EXIT /b)
    CALL :unpack "%srcpath%1Cv77_BIN.7z"
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%prog1sDir%\BIN\1cv7s.exe" /d "DisableNXShowUI" /f
POPD

MKDIR "%commonRarusDir%"
PUSHD "%commonRarusDir%"||(PAUSE&EXIT /b)
    XCOPY "%srcpath%D_1S_Rarus_ShopBTS" "%commonRarusDir%" /D /E /C /Y ||PAUSE
POPD
PUSHD "%SystemRoot%"||(PAUSE&EXIT /b)
    CALL :unpack "%srcpath%SystemRoot.7z"
    REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%SystemRoot%\Eutron\Eutron.exe" /d "DisableNXShowUI" /f
POPD

PUSHD "%prog1sDir%\BIN"||(PAUSE&EXIT /b)
    CALL register_all_components.cmd
    ECHO ON
POPD

PUSHD "%commonRarusDir%"||(PAUSE&EXIT /b)
    IF EXIST "%rarusConfigbaseDir%" GOTO :skipExtractingRarusBase
    CALL :UnpackInitialBase||PAUSE
    IF NOT EXIST "%rarusConfigbaseDir%\Exchange" MKDIR "%rarusConfigbaseDir%\Exchange"
    PUSHD "%rarusConfigbaseDir%\Exchange"||(PAUSE&EXIT /b)
	CALL :unpack "%srcpath%Exchange.7z"
    POPD
:skipExtractingRarusBase
POPD

PUSHD "%SystemRoot%\Eutron"||(PAUSE&EXIT /b)
    eutron.exe
POPD

CALL "%srcpath%_shedule_backup1Sbase.cmd"
CALL "%srcpath%_shedule_rsend_queue.cmd"

EXIT /B
:UnpackInitialBase
    FOR %%I IN ("%ShopBTS_InitialBase_archive%") DO SET ShopBTS_InitialBase_archive=%%I
    MKDIR "%rarusConfigbaseDir%"
    PUSHD "%rarusConfigbaseDir%"||(PAUSE&EXIT /b)
        CALL :unpack "%commonRarusDir%\%ShopBTS_InitialBase_archive%"||PAUSE
        CALL :unpack "%commonRarusDir%\ShopBTS_Add.7z"||PAUSE
        CALL :unpack "%commonRarusDir%\ShopBTS_Add_DLLs.7z"||PAUSE
        CALL register_all_components.cmd
    POPD
EXIT /B

:unpack
    CALL :findExtractor %~x1||EXIT /B 2
    GOTO :unpack%~x1
EXIT /B 2
:unpack.7z
    %unpacker% x -r -y -- %1
EXIT /B
:unpack.nz
    %unpacker% x -r -y -- %1
EXIT /B
:unpack.bak
    %unpacker% Skipping %1
EXIT /B

:findExtractor
    REM "executable not found" ERRORLEVEL 9009
    SET ext=%1
    SET ext=%ext:~1%
    SET unpacker=%ext%.exe
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%utilsdir%%ext%.exe"
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%srcpath%..\..\..\PreInstalled\utils\%ext%.exe"
    %unpacker%>NUL&&EXIT /B

    GOTO :findExtractor%1
EXIT /B 2

:findExtractor.7z
    SET unpacker=7za.exe
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%SystemDrive%\Arc\7-Zip\7z.exe"
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%SystemDrive%\Arc\7-Zip\7za.exe"
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%utilsdir%7za.exe"
    %unpacker%>NUL&&EXIT /B
EXIT /B 2

:findExtractor.nz
    SET unpacker="%SystemDrive%\Arc\NanoZip\nz.exe"
    %unpacker%>NUL&&EXIT /B
    SET unpacker="%utilsdir%nz.exe"
    %unpacker%>NUL&&EXIT /B
EXIT /B 2

:findExtractor.bak
    SET unpacker=ECHO 
EXIT /B 2
