@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
REM TODO: determine OS, and run corresponding installer
IF NOT DEFINED ErrorCmd SET ErrorCmd=CALL :ErrorHandler
IF NOT DEFINED exe7z CALL :find7zexe

CALL :TryLocalCopy "d:\Distributives\Drivers\Realtek\Audio\High_Definition_Audio_Codecs"

IF "%~1"=="" (
    CALL :CheckWinVer 6.4 && CALL :findSource *UAD* *Win10* || SET "source="
    IF NOT DEFINED source CALL :CheckWinVer 6.3 && CALL :findSource *Win81* || SET "source="
    IF NOT DEFINED source CALL :CheckWinVer 6.2 && CALL :findSource *Win8* || SET "source="
    IF NOT DEFINED source CALL :CheckWinVer 6.1 && CALL :findSource *Win7* || SET "source="
    IF NOT DEFINED source CALL :findSource *.* || EXIT /B
) ELSE CALL :findSource %1 || EXIT /B

SET "log=%TEMP%\%~n0.log"
SET "setupwrittenlog=%SystemDrive%\RHDSetup.log"
SET "tempdst=%TEMP%\RealtekHDA-%~n0"
)
(
%exe7z% x -r -o"%tempdst%" -- "%source%"||%ErrorCmd%

PUSHD "%tempdst%" && (
    IF EXIST Guru3D.com CD Guru3D.com
    IF EXIST Setup* CD Setup*

    IF NOT EXIST setup.exe FOR /D %%I IN (*.*) DO (
rem 	IF EXIST "%%~I\WDM\setup.exe" CD "%%~I\WDM"
	IF EXIST "%%~I\setup.exe" CD "%%~I"
    )
    setup.exe -s -z || %ErrorCmd%
    REM /f2"%log%" doesn't work
POPD
)

RD /S /Q "%tempdst%"
MOVE /Y "%setupwrittenlog%" "%log%"
DEL "%SystemDrive%\csb.log" "%SystemDrive%\Install.log"

CALL "%~dp0RemoveFromStartup.cmd"
EXIT /B
)
:ErrorHandler
(
    ECHO Error %ERRORLEVEL% occured.
    PAUSE
EXIT /B
)
:findSource <path_or_mask> <...>
SET "mask=%~1"
(
    SET "relPath=1"
    IF "%mask:~0,1%"=="\" SET "relPath="
    IF "%mask:~1,1%"==":" SET "relPath="
    IF DEFINED relPath (
        SET "maskDir=%srcpath%"
    ) ELSE (
        SET "maskDir=%~dp1"
        SET "mask=%~nx1"
    )
)
(
    FOR /F "usebackq delims=" %%I IN (`DIR /O-D /B "%maskDir%%mask%"`) DO (
	IF "%%~xI"==".exe" SET "source=%maskDir%%%~I" & EXIT /B
	IF "%%~xI"==".7z" SET "source=%maskDir%%%~I" & EXIT /B
	IF "%%~xI"==".zip" SET "source=%maskDir%%%~I" & EXIT /B
    )
    
    IF NOT "%~2"=="" (
        SHIFT
        GOTO :findSource
    )
EXIT /B 1
)
:TryLocalCopy <localDest>
(
IF EXIST "%~d1\*.*" (
    IF NOT EXIST %1 MKDIR %1
    XCOPY "%~dp0*.*" "%~1\" /E /C /I /H /K /Y && SET "srcpath=%~1\"
)
EXIT /B
)
:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation"`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString"`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)
EXIT /B
)
:checkDirFrom1stArg <arg1> <anything else>
(
    CALL :Check7zDir "%~dp1"
EXIT /B
)
:Check7zDir <dir>
    IF NOT "%~1"=="" SET "dir7z=%~1"
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
(
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" <NUL >NUL 2>&1 || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B
)
:findexe
    (
    SET "locvar=%~1"
    SET "seekforexecfname=%~nx2"
    )
    (
    FOR /D %%I IN ("%~dp2") DO IF EXIST "%%~I%seekforexecfname%" CALL :testexe %locvar% "%%~I%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    FOR /R "%SystemDrive%\SysUtils" %%I IN (.) DO IF EXIST "%%~I\%seekforexecfname%" CALL :testexe %locvar% "%%~I\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Server.local\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Server.local\profiles$\Share\Programs\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT /3
    GOTO :findexeNextPath
    )
    :testexe
    (
	IF "%~2"=="" EXIT /B 9009
	IF NOT EXIST "%~dp2" EXIT /B 9009
	"%~2" <NUL >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %~1="%~2"
    EXIT /B
    )

:CheckWinVer
@(REM coding:CP866
rem \\Server.local\Users\Public\Shares\profiles$\Share\config\_Scripts\CheckWinVer.cmd
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

SET "OSWordSize=32"
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OSWordSize=64"
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET "OSWordSize=64"
FOR /F "usebackq delims=" %%W IN (`ver`) DO SET "VW=%%W"
)
IF "%VW:~0,24%"=="Microsoft Windows 2000 [" (
    REM 2K: Microsoft Windows 2000 [Версия 5.00.2195]
    SET "WinVerNum=5.0"
) ELSE IF "%VW:~0,22%"=="Microsoft Windows XP [" (
    REM XP: Microsoft Windows XP [Version 5.1.2600]
    SET "WinVerNum=5.1"
) ELSE (
    IF "%VW:~0,27%"=="Microsoft Windows [Version " SET "WinVerNum=%VW:~27,-1%"
    IF "%VW:~0,26%"=="Microsoft Windows [Версия " SET "WinVerNum=%VW:~26,-1%"
)

(
IF "%~1"=="" EXIT /B
SETLOCAL
rem Compare Windows version with %1 by parts as numbers.
rem This is required because string "10." is less (<, LSS) than "5.0".

rem returns 1 if version provided via command line is greater than windows version
rem %0 6 to check for Vista-or-higher --- equivalent to %0 6.0
rem %0 6.1 to check for Windows 7 / Server 2008 R2 or higher
rem %0 6.2 to check for Windows 8 / Server 2012 or higher
rem %0 6.3 to check for Windows 8.1 / Server 2012 R2 or higher
rem %0 6.4 to check for Windows 10 or higher
rem actually current Win10 versions return "10" as their primary version number, but early preview builds returned 6.4. And it script for higher-or-equal anyway, so 6.4 will work reliably.

FOR /F "delims=. tokens=1,2,3" %%I IN ("%WinVerNum%") DO (
    SET "verSub1=%%I"
    SET "verSub2=%%J"
    SET "verSub3=%%K"
)
FOR /F "delims=. tokens=1,2,3" %%I IN ("%~1") DO (
    SET "chkSub1=%%I"
    SET "chkSub2=%%J"
    SET "chkSub3=%%K"
)
IF NOT DEFINED verSub3 SET "verSub3=0"
IF NOT DEFINED chkSub2 SET "chkSub2=0"
IF NOT DEFINED chkSub3 SET "chkSub3=0"
)
(
ENDLOCAL
IF %chkSub1% GTR %verSub1% EXIT /B 1
IF %chkSub1% LSS %verSub1% EXIT /B 0
IF %chkSub2% GTR %verSub2% EXIT /B 1
IF %chkSub2% LSS %verSub2% EXIT /B 0
IF %chkSub3% GTR %verSub3% EXIT /B 1
EXIT /B 0
)
