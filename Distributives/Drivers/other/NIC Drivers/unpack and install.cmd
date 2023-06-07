(
@REM coding:OEM
REM src: http://texhex.blogspot.ru/2009/10/installing-windows-7-drivers-from.html
SETLOCAL ENABLEEXTENSIONS

SET "destStd=d:\Distributives\Drivers_local\NIC"
SET "destAlt=%TEMP%\NIC Drivers"
SET dpinsttype=32-bit
SET exe7z="%~dp07za.exe"
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" CALL :set64bit
IF "%PROCESSOR_ARCHITEW6432%"=="AMD64" CALL :set64bit
)
(
MKDIR "%destStd%"
    IF EXIST "%destStd%\." (
	SET "dest=%destStd%"
    ) ELSE (
	SET "dest=%destAlt%"
    )
)
(
CALL "%~dp0unpack NIC Drivers.cmd"
%exe7z% e -o"%dest%" -- "%~dp0dpinst.7z" "dpinst.xml" "%dpinsttype%\*"
START "" /D "%dest%" /WAIT dpinst.exe
)
EXIT /B

:set64bit
(
SET "dpinsttype=64-bit"
IF EXIST "%~dp07za-x64.exe" SET exe7z="%~dp07za-x64.exe"
EXIT /B
)
