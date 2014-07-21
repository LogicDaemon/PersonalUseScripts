@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF NOT DEFINED ProgramData SET "ProgramData=%ALLUSERSPROFILE%\Application Data"
IF NOT EXIST "%ProgramData%\mobilmir.ru\Common_Scripts" IF EXIST "%SystemDrive%\Common_Scripts" MOVE /Y "%SystemDrive%\Common_Scripts" "%ProgramData%\mobilmir.ru\Common_Scripts"
%windir%\System32\compact.exe /C /EXE:LZX /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q || %windir%\System32\compact.exe /C /S:"%ProgramData%\mobilmir.ru\Common_Scripts" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramData%\mobilmir.ru\Common_Scripts"
"%utilsdir%xln.exe" -n "%ProgramData%\mobilmir.ru\Common_Scripts" "%SystemDrive%\Common_Scripts"
