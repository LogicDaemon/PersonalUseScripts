@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET InstDistributive=%srcpath%Firefox Setup *.exe
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
)

FOR /F "usebackq delims=" %%I IN (`ver`) DO SET "WinVer=%%I"
IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" SET InstDistributive=%srcpath%W2K\Firefox Setup 12.0 ru.exe

FOR %%I IN ("%InstDistributive%") DO SET InstDistributive=%%~I
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%

SET TempIni=%TEMP%\FirefoxInstall.ini

SET ProgramFiles=%ProgramFiles:\=\\%
COPY /B "%srcpath%install.ini" "%TempIni%"
IF DEFINED sedexe %sedexe% "s/;InstallDirectoryPath={InstallDirectoryPath}/InstallDirectoryPath=%ProgramFiles%\\Mozilla Firefox/" "%srcpath%install.ini">"%TempIni%"
"%InstDistributive%" /INI="%TempIni%"

IF ERRORLEVEL 1 SET ErrorMemory=%ERRORLEVEL%
SET MozMainSvcUninst=%ProgramFiles%\Mozilla Maintenance Service\Uninstall.exe
IF EXIST "%MozMainSvcUninst%" "%MozMainSvcUninst%" /S

REM Copying defaults and fixed
IF EXIST "%DefaultsSource%" CALL :UnpackDefaults
CALL :HideDesktopShortcut

EXIT /B %ErrorMemory%

:UnpackDefaults
    CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "c:\Arc\7-Zip\7z.exe" || (ECHO  & EXIT /B 32767)
    %exe7z% x -aoa -r0 -o"%ProgramFiles%\" -- "%DefaultsSource%" "Mozilla Firefox\"
EXIT /B

:HideDesktopShortcut
    REM Hiding desktop shortcut
    SET RegQueryParsingOptions="usebackq tokens=3* delims= "
    FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
    IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" GOTO :IncludeRecoding
    IF "%WinVer:~0,22%"=="Microsoft Windows XP [" GOTO :IncludeRecoding
    GOTO :SkipRecoding
:IncludeRecoding
    rem     there's tab in end of next line. It's mandatory
    SET RegQueryParsingOptions="usebackq tokens=2* delims=	"

    IF NOT DEFINED recodeexe CALL :findexe recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
    IF DEFINED recodeexe SET recodecmd=^^^|%recodeexe% -f --sequence=memory 1251..866
:SkipRecoding

    FOR /F %RegQueryParsingOptions% %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop" %recodecmd%`) DO SET CommonDesktop=%%J
    IF NOT DEFINED CommonDesktop EXIT /B
    FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET CommonDesktop=%%I

    ATTRIB +H "%CommonDesktop%\Mozilla Firefox.lnk"

EXIT /B


:findexe
    (
    REM %1 variable which will get location
    REM %2 executable file name
    REM %3... additional paths with filename (including masks) to look through
    REM ERRORLEVEL 3 The system cannot find the path specified.
    REM ERRORLEVEL 9009 'test.exe' is not recognized as an internal or external command, operable program or batch file.

    SET locvar=%1
    SET seekforexecfname=%~2
    )
    (
    REM checking simplest variant -- when executable in in %PATH%
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM checking paths suggestions
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    REM following is relative to containing-script-location
    CALL :testexe %locvar% "%srcpath%..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
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
	"%~2" >NUL 2>&1
	IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
	SET %1=%2
    )
EXIT /B
