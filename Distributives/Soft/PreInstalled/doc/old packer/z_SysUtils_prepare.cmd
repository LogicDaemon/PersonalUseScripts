@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

START "" /D"c:\SysUtils\Piriform" /B /WAIT %comspec% /C update_winapp2.cmd

IF "%~1"=="" GOTO :noargs
SET arg=%~1
IF DEFINED arg IF "%arg:~0,1%"=="/" GOTO :arg.%arg:~1%

:noargs
CALL :arg.7z
rem CALL :arg.nz

EXIT /B

:arg.7z
IF EXIST "%srcpath%auto\SysUtils.7z" MOVE /Y "%srcpath%auto\SysUtils.7z" "%srcpath%auto\SysUtils.bak.7z"
IF EXIST "%srcpath%auto\SysUtils-bigrarelyused.7z" MOVE /Y "%srcpath%auto\SysUtils-bigrarelyused.7z" "%srcpath%auto\SysUtils-bigrarelyused.bak.7z"
IF EXIST "%srcpath%manual\SysUtils.7z" MOVE /Y "%srcpath%manual\SysUtils.7z" "%srcpath%manual\SysUtils.bak.7z"

CALL 7z_get_switches.cmd

TITLE Compressing main files
START "" /B /D"%SystemDrive%\SysUtils" /WAIT 7z a -r %z7zswitchesLZMA2BCJ2% -x@"%~dp0z_SysUtils_commonexcludes.list" -x@"%~dp0z_SysUtils_manual.list" -x@"%~dp0z_SysUtils_bigrarelyused.list" -x@"%~dp0z_SysUtils_nonfree.list" -- "%srcpath%auto\SysUtils.7z" && DEL "%srcpath%auto\SysUtils.bak.7z"
TITLE Compressing big and rare used
START "" /B /D"%SystemDrive%\SysUtils" /WAIT 7z a -r %z7zswitchesLZMA2BCJ2% -i@"%~dp0z_SysUtils_bigrarelyused.list" -x@"%~dp0z_SysUtils_commonexcludes.list" -- "%srcpath%auto\SysUtils-bigrarelyused.7z" && DEL "%srcpath%auto\SysUtils-bigrarelyused.bak.7z"
TITLE Compressing files for manual extraction
START "" /B /D"%SystemDrive%\SysUtils" /WAIT 7z a -r %z7zswitchesLZMA2BCJ2% -i@"%~dp0z_SysUtils_manual.list" -x@"%~dp0z_SysUtils_commonexcludes.list" -- "%srcpath%manual\SysUtils.7z" && DEL "%srcpath%manual\SysUtils.bak.7z"

EXIT /B

:arg.nz

IF EXIST "%srcpath%auto\SysUtils.nz" MOVE /Y "%srcpath%auto\SysUtils.nz" "%srcpath%auto\SysUtils.bak.nz"
IF EXIST "%srcpath%manual\SysUtils.nz" MOVE /Y "%srcpath%manual\SysUtils.nz" "%srcpath%manual\SysUtils.bak.nz"

CALL nz_get_switches.cmd

START /B /D"%SystemDrive%\SysUtils" /WAIT nz a -r %znzswitchesnz_cm% -x@"%~dp0z_SysUtils_commonexcludes.list" -x@"%~dp0z_SysUtils_manual.list" -x@"%~dp0z_SysUtils_nonfree.list" -- "%srcpath%auto\SysUtils.nz" && DEL "%srcpath%auto\SysUtils.bak.nz"
START /B /D"%SystemDrive%\SysUtils" /WAIT nz a -r %znzswitchesnz_cm% -x@"%~dp0z_SysUtils_commonexcludes.list" -i@"%~dp0z_SysUtils_manual.list" -- "%srcpath%manual\SysUtils.nz" && DEL "%srcpath%manual\SysUtils.bak.nz"

EXIT /B
