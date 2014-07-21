@REM coding:OEM

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
IF NOT DEFINED ErrorCmd (
    SET ErrorCmd=SET ErrorPresence=1
    SET ErrorPresence=0
    IF "%RunInteractiveInstalls%"=="1" SET ErrorCmd=ECHO `&SET ErrorPresence=1
)

CALL _get_defaultconfig_source.cmd

IF NOT DEFINED exe7z CALL "%~dp0find_exe.cmd" exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL "%~dp0find_exe.cmd" exe7z 7z.exe || EXIT /B

REM SET dist="%srcpath%Opera_*_int_Setup.exe"
SET distmask=int\Opera_*_int_Setup.exe

FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" SET distmask=W2K\*.exe

rem FOR /F "usebackq delims=" %%I IN (`ver`) DO SET WinVer=%%I
rem IF "%WinVer:~0,24%"=="Microsoft Windows 2000 [" SET distmask=W2K\Opera_*_int_Setup.exe

SET OperaInstallerOptions=%OperaInstallerOptions% /setdefaultbrowser

REM Opera 11 installer options:
REM When launching the installer from the command line, you have a number of options available:
REM /installfolder <folder> : Where to install. This will be reflected in the wizard.
REM /silent : Skips the wizard and installs directly, using the options set on the command line
REM 
REM 
REM The following options are currently only working in Silent mode:
REM /copyonly : Only copies the files to the installation folder and does *nothing* else. All other options are ignored, except /singleprofile
REM /allusers : If used, shortcuts will be created in the common profile folders and registry changes will be done on HKEY_LOCAL_MACHINE (system wide). Otherwise, shortcuts are created in the user profile folders and registry changes will only touch HKEY_CURRENT_USER.
REM /singleprofile : Writes operaprefs_default.ini to specify that the profile folder is to be created/found under the installation folder (previously called single user).
REM /setdefaultbrowser : Sets opera as the default browser once the installation has completed.
REM /nostartmenushortcut : Don't create a start menu shortcut.
REM /nodesktopshortcut : Don't create a desktop shortcut.
REM /noquicklaunchshortcut : Don't create a quick launch shortcut.
REM /launchopera : Launches Opera once the installation has completed.

FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find.exe "%srcpath:~0,-1%" -path "%distmask%" -maxdepth 2`) DO SET dist=%%~I
IF NOT DEFINED dist FOR %%I IN ("%srcpath%%distmask%") DO SET dist=%%~I
IF NOT DEFINED dist %ErrorCmd%

FOR /F "usebackq tokens=2 delims==" %%I IN (`FTYPE AutoHotkeyScript`) DO SET ahkexe=%%I
IF NOT DEFINED ahkexe CALL :findexe ahkexe AutoHotkey.exe "..\..\..\PreInstalled\utils\AutoHotkey.exe"

IF DEFINED ahkexe (
    CALL :RunAHK %ahkexe%
) ELSE (
REM for now the installer is buggy, do not change order of arguments
    %dist% /silent /allusers
rem  %OperaInstallerOptions%
rem /installfolder "%ProgramFiles%\Opera"
)

CALL "%~dp0ExtractSettings.cmd"

EXIT /B 0
rem %ErrorPresence%

:RunAHK
    START "InstallWaitKill.ahk" /WAIT /D "%srcpath%" %1 "%srcpath%InstallWaitKill.ahk" %dist%
EXIT /B
