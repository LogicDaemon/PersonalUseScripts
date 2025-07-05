@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
	SET "dest=%LocalAppData%\Programs\Total Commander\"
	SET "src=%~dp0"
)
@(
	IF /I "%dest%"=="%src%" (
		ECHO FFS dest=src :-[
		EXIT /B 1
	)
	IF NOT EXIST "%dest%" (
		ECHO [*] "%dest%" does not exist
		EXIT /B 1
	)
	FOR /F "usebackq delims=" %%A IN (`DIR /S /A-L-D /B "%~dp0*.*"`) DO @(
		SET "pathSrcFile=%%~A"
		SET "pathDestFile=%dest%!pathSrcFile:%src%=!"
		IF EXIST "!pathDestFile!" (
		FC "%%~A" "!pathDestFile!" >NUL
		IF ERRORLEVEL 2 (
			SET "skip=2"
			ECHO [*] Error comparing "%%~A"
		) ELSE IF ERRORLEVEL 1 (
			SET "skip="
			ECHO [*] "%%~A" is different
			MOVE /Y "!pathDestFile!" "!pathDestFile!.bak" || PAUSE
		) ELSE ( REM files are the same
			SET "skip="
			ECHO [-] "!pathDestFile!"
			DEL "!pathDestFile!"
		)
		) ELSE ( REM !pathDestFile! does not exist
			SET "skip="
		)
		IF NOT DEFINED skip (
			REM symlinks require admin rights
			MKLINK "!pathDestFile!" "%%~A" || MKLINK /H "!pathDestFile!" "%%~A"
		)
	)
EXIT /B
)
