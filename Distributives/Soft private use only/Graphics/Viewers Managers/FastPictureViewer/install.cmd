@REM coding:OEM
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

FOR %%I IN ("%srcpath%FastPictureViewer*.zip") DO SET SourceArchive=%%I
IF NOT "%~1"=="" SET SourceArchive=%~1
IF NOT EXIST "%SourceArchive%" (
    IF EXIST "%srcpath%%SourceArchive%" (SET SourceArchive=%srcpath%%SourceArchive%) ELSE EXIT /b 1
)

SET MSIfile=FastPictureViewer.msi
SET TmpDst=%TEMP%\FastPictureViewer\

IF NOT DEFINED ErrorCmd SET ErrorCmd=PAUSE
SET ErrorPresence=0

7z x -o"%TmpDst%" "%SourceArchive%" "%MSIfile%"||SET ErrorPresence=1
IF NOT DEFINED logmsi SET logmsi=%TEMP%\%~n0.log
msiexec /i "%TmpDst%FastPictureViewer.msi" /passive /norestart /l+* "%logmsi%"
IF ERRORLEVEL 1 SET ErrorPresence=1
RD /S /Q "%TmpDst%"||SET ErrorPresence=1

IF "%ErrorPresence%"=="1" %ErrorCmd%
EXIT /b
