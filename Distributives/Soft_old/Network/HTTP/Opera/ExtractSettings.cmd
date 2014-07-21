@REM coding:OEM

SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF NOT DEFINED exe7z CALL "%~dp0find_exe.cmd" exe7z 7za.exe "%SystemDrive%\Arc\7-Zip\7za.exe" "%SystemDrive%\Arc\7-Zip\7z.exe" || CALL "%~dp0find_exe.cmd" exe7z 7z.exe || EXIT /B
IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
IF NOT DEFINED ErrorCmd (
    SET ErrorCmd=SET ErrorPresence=1
    SET ErrorPresence=0
    IF "%RunInteractiveInstalls%"=="1" SET ErrorCmd=ECHO `&SET ErrorPresence=1
)

CALL _get_defaultconfig_source.cmd
IF DEFINED DefaultsSource IF NOT DEFINED SetDefaults SET SetDefaults=1

IF NOT DEFINED AddSettings SET AddSettings=settings.7z

%exe7z% x -aoa -o"%ProgramFiles%" -- "%srcpath%%AddSettings%"||%ErrorCmd%

IF NOT "%SetDefaults%"=="0" (
    REM Copying defaults and fixed
    IF EXIST "%DefaultsSource%" (
	7z e -aoa -o"%SystemRoot%\System32\" -- "%DefaultsSource%" Opera\fixed\*.ini||%ErrorCmd%
	7z x -aoa -r0 -o"%ProgramFiles%\" -- "%DefaultsSource%" Opera\*||%ErrorCmd%
    )
)
