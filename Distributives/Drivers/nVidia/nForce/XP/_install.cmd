@REM coding:OEM

SET srcpath=%~dp0
SET distname=15.45_nforce_winxp32_international_whql.exe
SET tempdst=%TEMP%\15.45_nforce_winxp32_international_whql

MKDIR d:\Distributives
IF EXIST d:\Distributives (
    IF NOT EXIST "d:\Distributives\Drivers\nVidia\nForce\XP" MKDIR "d:\Distributives\Drivers\nVidia\nForce\XP"
    XCOPY /E /C /I /H /K /Y "%~dp0*.*" "d:\Distributives\Drivers\nVidia\nForce\XP\"
    IF NOT ERRORLEVEL 1 SET srcpath=d:\Distributives\Drivers\nVidia\nForce\XP\
)

IF NOT DEFINED exe7z CALL :find7z
%exe7z% x -aoa -r -o"%tempdst%" -xr!"NAMSetup.exe" -- "%srcpath%%distname%"

PUSHD "%tempdst%"
    REM BootOption=0 don't work
    ECHO BootOption=0 >>setup.iss
    setup.exe /s /z
POPD

PUSHD "%SystemRoot\System32"
    regsvr32 /u /s nvcpl.dll
    regsvr32 /u /s nvshell.dll
POPD

CALL "%~dp0RemoveFromStartupAndContextMenu.cmd"

RD /S /Q "%tempdst%"

EXIT /B
:find7z
    IF EXIST "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" (
	CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7z.exe
	IF ERRORLEVEL 9009 CALL "\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd" exe7z 7za.exe
    )
    IF NOT DEFINED exe7z CALL :findexe exe7z 7z.exe
    IF NOT DEFINED exe7z CALL :findexe exe7z 7za.exe
    IF NOT DEFINED exe7z SET exe7z=7z.exe
EXIT /B

:findexe
    REM %1 variable which will get location
    REM %2 executable file name
    REM %3... additional paths to look through

    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.

    CALL :testexe %1 %2
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF DEFINED srcpath IF EXIST "%srcpath%" CALL :testexe %1 "%srcpath%%~2"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF DEFINED utilsdir IF EXIST "%utilsdir%" CALL :testexe %1 "%utilsdir%%~2"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF EXIST "\\Srv-Net\Soft\PreInstalled\utils\" CALL :testexe %1 "\\Srv-Net\Soft\PreInstalled\utils\%~2"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B
    IF EXIST "\Distributives\Soft\PreInstalled\utils\" CALL :testexe %1 "\Distributives\Soft\PreInstalled\utils\%~2"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B

    :findexeNextPath
    IF "%~3" == "" GOTO :testexe
    REM previous line causes attempt to exec %2 and EXIT /B 9009 to original caller

    IF EXIST "%~3" CALL :testexe %1 "%~3%~2"
    IF NOT "%ERRORLEVEL%"=="9009" EXIT /B

    SHIFT
    GOTO :findexeNextPath

    :testexe
    IF NOT EXIST "%~dp2" EXIT /B 9009
    %2 >NUL 2>&1
    IF NOT "%ERRORLEVEL%"=="9009" SET %1=%2
EXIT /B
