@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS

SET cppdistpath=%~dp0..\..\..\Updates\Windows\wsusoffline\cpp

IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET inst64bit=1
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET inst64bit=1

IF NOT "%inst64bit%"=="1" GOTO :CPPInstx86
:CPPInstxx64
"%cppdistpath%\vcredist2005_x64.exe" /Q /r:n
"%cppdistpath%\vcredist2008_x64.exe" /q /r:n
"%cppdistpath%\vcredist2010_x64.exe" /q /norestart
"%cppdistpath%\vcredist2012_x64.exe" /q /norestart
:CPPInstx86
"%cppdistpath%\vcredist2005_x86.exe" /Q /r:n
"%cppdistpath%\vcredist2008_x86.exe" /q /r:n
"%cppdistpath%\vcredist2010_x86.exe" /q /norestart
"%cppdistpath%\vcredist2012_x86.exe" /q /norestart
