@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions
IF "%srcpath%"=="" SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
SET utilsdir=%srcpath%..\..\..\PreInstalled\utils\

SET InstTempDir=%TEMP%\Adobe Reader Install
SET InstSource=%srcpath%AdbeRdr*_ru_RU.*
SET MSIFile=AcroRead.msi
SET MSITransformArchive=%srcpath%AcroRead9.7z
SET MSITransformFile=AcroRead.mst

FOR %%I IN ("%InstSource%") DO SET InstSource=%%I

IF "%InstSource%"=="" EXIT /B 2

IF NOT EXIST "%InstTempDir%" MKDIR "%InstTempDir%"
PUSHD "%InstTempDir%"||EXIT /B 2
    CALL :unpack "%InstSource%" && CALL :unpack "%MSITransformArchive%" && msiexec.exe /i "%msifile%" /t"%MSITransformFile%" /qn /norestart
POPD
RD /S /Q "%InstTempDir%"
CALL "%srcpath%install_updates9.cmd"

REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Adobe ARM" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Adobe Reader Speed Launcher" /f

FOR /F "usebackq tokens=2* delims=	" %%I IN (`REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Common Desktop"^|recode -f --sequence=memory 1251..866`) DO SET CommonDesktop=%%J
IF NOT DEFINED CommonDesktop GOTO :SkipHidingShortcut
FOR /F "usebackq delims=" %%I IN (`%comspec% /C ECHO %CommonDesktop%`) DO SET CommonDesktop=%%I
ATTRIB +H "%CommonDesktop%\Adobe Reader *.lnk"
::SkipHidingShortcut

EXIT /B
:unpack
IF NOT "%~x1"==".exe" CALL :findExtractor %~x1||EXIT /B 2
GOTO :unpack%~x1
EXIT /B 2
:unpack.exe
%1 -nos_ne -nos_o.
EXIT /B
:unpack.7z
%unpacker% x -r -aoa -- %1
EXIT /B
:unpack.nz
%unpacker% x -r -y -- %1
EXIT /B

:findExtractor
REM "executable not found" ERRORLEVEL 9009
SET ext=%1
SET unpacker=
IF "%ext%"==".exe" EXIT /B
SET ext=%ext:~1%

REM TODO: the following is archaic, must be replaced with PreInstalled\doc\find_exe.cmd

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
