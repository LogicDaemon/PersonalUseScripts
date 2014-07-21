@REM coding:CP866

IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
SET argv=%~1
SET argflag=%argv:~,1%
SET option=%argv:~1%

IF "%argflag%"=="/" (
    SHIFT
    GOTO :arg_%option%
)

:arg_Import
    SET RegConfigName=%~1
    IF "%RegConfigName%"=="" SET RegConfigName=TeamViewer_host.reg

    IF NOT EXIST "%RegConfigName%" (
	IF NOT DEFINED DefaultsSource CALL "%ProgramData%\mobilmir.ru\_get_defaultconfig_source.cmd" || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
	rem finding 7z here because it's only needed to extract regconfig from defaultssource location. Otherwise, plain pre-extracted REG is used.
	IF NOT DEFINED exe7z CALL :find7zexe
    )

    IF NOT EXIST "%RegConfigName%" (
	SET del=1
	%exe7z% e -aoa -o"%TEMP%" -- "%DefaultsSource%" "TeamViewer\%RegConfigName%"
	SET RegConfigName=%TEMP%\%RegConfigName%
    )
    REG IMPORT "%RegConfigName%"
    IF "%del%"=="1" DEL "%RegConfigName%"

EXIT /B

:arg_PostInstall
    REM Posting data to TeamViewer Install Info form
    IF NOT DEFINED DefaultsSource CALL _get_defaultconfig_source.cmd
    IF NOT EXIST "%AutohotkeyExe%" CALL :FindAutohotkeyExe
    START "" /B %AutohotkeyExe% /ErrorStdOut "%srcpath%PostFormData.ahk"
    SET "TVProgramFiles=%ProgramFiles(x86)%\TeamViewer\Version5"
    IF NOT EXIST "%TVProgramFiles%\TV.dll" SET TVProgramFiles=%ProgramFiles%\TeamViewer\Version5
    "%windir%\System32\netsh.exe" advfirewall firewall add rule name="Teamviewer Remote Control Application" dir=in action=allow program="%TVProgramFiles%\TeamViewer.exe" edge=yes
    "%windir%\System32\netsh.exe" advfirewall firewall add rule name="Teamviewer Remote Control Service" dir=in action=allow program="%TVProgramFiles%\TeamViewer_Service.exe" edge=yes
    
    REM When uninstalling, TV schedules removal of leftover files from its dir. When resinstalling, it does not remove this pending move command, so it stops working after next reboot.
    REM to avoid that, copy these files and schedule their move to normal location.
    REG ADD "HKEY_CURRENT_USER\Software\Sysinternals\Movefile" /v "EulaAccepted" /t REG_DWORD /d 1 /f
    IF NOT DEFINED movefileexe CALL :findexe movefileexe movefile.exe
    IF NOT DEFINED movefileexe GOTO :skipNormalizingTV
    PUSHD "%TVProgramFiles%" || GOTO :skipNormalizingTV
	FOR %%I IN (*.dll *.exe) DO (
	    xln "%%~I" "%%~I.copy" || COPY /B "%%~I" "%%~I.copy"
	    %movefileexe% "%%~I.copy" "%%~I"
	)
    POPD
    :skipNormalizingTV
    
    REM Hiding Desktop Shortcut
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

    ATTRIB +H "%CommonDesktop%\TeamViewer*.lnk"
    
    START "" %comspec% /C "%SystemRoot%\System32\ping.exe 127.0.0.1 -n 15>NUL & %SystemRoot%\System32\net.exe start TeamViewer"
EXIT /B

:FindAutohotkeyExe
FOR /F "usebackq tokens=2 delims==" %%I IN (`ftype AutoHotkeyScript`) DO CALL :GetFirstArg AutohotkeyExe %%I
GOTO :SkipGetFirstArg
:GetFirstArg
    SET %1=%2
EXIT /B
:SkipGetFirstArg

IF DEFINED AutohotkeyExe IF EXIST %AutohotkeyExe% EXIT /B 0
rem continuing here if AutoHotkeyScript isn't defined or specified path points to incorect location

SET AutohotkeyExe="%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%ProgramFiles(x86)%\AutoHotkey\AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% IF DEFINED utilsdir SET AutohotkeyExe="%utilsdir%AutoHotkey.exe"
IF NOT EXIST %AutohotkeyExe% SET AutohotkeyExe="%~dp0..\..\..\..\PreInstalled\utils\AutoHotkey.exe"
IF EXIST %AutohotkeyExe% EXIT /B 0
SET AutohotkeyExe=
EXIT /B 1

:tryutilsdir
    
EXIT /B

:FindSoftwareSource
    CALL :CheckSetSoftSource "%~d0\Distributives\Soft" || CALL :CheckSetSoftSource "%~dp0..\..\Soft" ( || CALL :CheckSetSoftSource "%~d0\Soft" || CALL :CheckSetSoftSource "\\Srv0\Distributives\Soft" || CALL :CheckSetSoftSource "\\Srv0.office0.mobilmir\Distributives\Soft" || EXIT /B 1

    SET utilsdir=%SoftSourceDir%PreInstalled\utils\

EXIT /B

:CheckSetSoftSource
    IF EXIST "%~1" (
	SET SoftSourceDir=%~f1\
	ECHO SoftSourceDir: %SoftSourceDir%
	EXIT /B 0
    )
EXIT /B 
:findexe
    (
    SET locvar=%1
    SET seekforexecfname=%~2
    )
    (
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED srcpath CALL :testexe %locvar% "%srcpath%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3" == "" GOTO :testexe
	REM previous line causes attempt to exec %2 and EXIT /B 9009 to original caller
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
	SHIFT
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

:find7zexe
(
    FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command" /ve /reg:64`) DO CALL :checkDirFrom1stArg %%B && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\7-Zip" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /v "Path" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "InstallLocation" /reg:64`) DO CALL :Check7zDir "%%~B" && EXIT /B
    IF NOT DEFINED exe7z FOR /F "usebackq tokens=2*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip" /v "UninstallString" /reg:64`) DO CALL :Check7zDir "%%~dpB" && EXIT /B

    CALL :findexe exe7z 7z.exe "%ProgramFiles%\7-Zip\7z.exe" "%ProgramFiles(x86)%\7-Zip\7z.exe" "%SystemDrive%\Program Files\7-Zip\7z.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL :findexe exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" || (ECHO  & EXIT /B 9009)
)

EXIT /B
:checkDirFrom1stArg <arg1> <anything else>
    CALL :Check7zDir "%~dp1"
EXIT /B

:Check7zDir <dir>
    IF NOT "%~1"=="" SET dir7z=%~1
    IF "%dir7z:~-1%"=="\" SET "dir7z=%dir7z:~0,-1%"
    IF NOT EXIST "%dir7z%\7z.exe" EXIT /B 9009
    "%dir7z%\7z.exe" >NUL 2>&1 <NUL || IF ERRORLEVEL 9009 IF NOT ERRORLEVEL 9010 EXIT /B
    SET exe7z="%dir7z%\7z.exe"
EXIT /B

:findexe
    (
    SET locvar=%1
    SET seekforexecfname=%~2
    )
    (
    CALL :testexe %locvar% %2 & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    IF DEFINED utilsdir CALL :testexe %locvar% "%utilsdir%%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "%srcpath%..\..\..\..\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\localhost\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    CALL :testexe %locvar% "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils\%seekforexecfname%" & ( IF NOT ERRORLEVEL 9009 EXIT /B & IF ERRORLEVEL 9010 EXIT /B )
    )
    :findexeNextPath
    (
	IF "%~3"=="" GOTO :testexe
	IF EXIST "%~3" FOR %%I IN ("%~3") DO CALL :testexe %locvar% "%%~I" & (
	    IF NOT ERRORLEVEL 9009 EXIT /B
	    IF ERRORLEVEL 9010 EXIT /B
	)
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
