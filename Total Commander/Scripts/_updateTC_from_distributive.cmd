@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

	IF NOT DEFINED dist (
		IF "%~1"=="" (
                    CALL :FindDistributive || EXIT /B
		) ELSE (
                    SET "dist=%~1"
                    SET "ext=%~x1"
		)
	)
	IF NOT DEFINED ext EXIT /B 1

	SET "baseDest=%~dp0..\"
)
(
	ECHO DIST: %DIST%
	PAUSE
	REM "%~dp0..\PlugIns\wcx\Total7zip\7zG.exe" x -aoa -o"%~dp0..\new" -- %1
	RD /S /Q "%TEMP%\TC_new"
	7z x -aoa -y -o"%TEMP%\TC_new" -- "%dist%"
	REM cabs are in https://www.ghisler.ch/install/beta/
	IF EXIST "%TEMP%\TC_new\INSTALL.CAB" (
		RD /S /Q "%TEMP%\TC_staging"
		MOVE "%TEMP%\TC_new" "%TEMP%\TC_staging"
		7z x -aoa -o"%TEMP%\TC_new" -- "%TEMP%\TC_staging\INSTALL.CAB"
		RD /S /Q "%TEMP%\TC_staging"
	)
	SET "dest=%baseDest%"
	FOR %%A IN ("%TEMP%\TC_new\*.*" "%TEMP%\TC_new\e\*.*") DO @CALL :TryMove "%%~A"
	SET "dest=%baseDest%LANGUAGE\"
	FOR %%A IN ("%baseDest%LANGUAGE\*.*") DO @CALL :TryMove "%%~A"
	RD /S /Q "%TEMP%\TC_new"
EXIT /B
)

:TryMove
@(
	ECHO Moving %1 "%dest%"
	MOVE /Y %1 "%dest%" || (
		MOVE /Y "%dest%%~nx1" "%dest%%~nx1.bak"
		MOVE /Y "%~1" "%dest%" || MOVE /Y "%~1" "%dest%%~nx1.new"
	)
	IF "%~2"=="" EXIT /B
	SHIFT
GOTO :MoveSrcs
)

:FindDistributive
@(
	SET "tcDistSubdir=Soft com license\Disk- File- Tools\File Managers\Total Commander"
	CALL :IsOS64Bit && CALL :FindDistributiveWithName "tcmd*x64.exe" ^
	|| CALL :FindDistributiveWithName "tcmd*x32_64.exe" ^
	|| CALL :FindDistributiveWithName "tcmd*x32.exe"
	EXIT /B
)
:FindDistributiveWithName <filename>
@CALL _Distributives.find_subpath.cmd dirDistributives "%tcDistSubdir%\%~1" || EXIT /B
@CALL :findlatest "%dirDistributives%\%tcDistSubdir%\%~1" || EXIT /B
(
	SET "dist=%latestFile%"
	SET "ext=%~x1"
EXIT /B
)

:IsOS64Bit
@(
	IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" EXIT /B 0
	IF DEFINED PROCESSOR_ARCHITEW6432 EXIT /B 0
EXIT /B 1
)

:findlatest <path>
@(
	FOR /F "usebackq delims=" %%A IN (`DIR /B /S /O-D %*`) DO @(
		SET "latestFile=%%~A"
		EXIT /B
	)
	EXIT /B 1
)
