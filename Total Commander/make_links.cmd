@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

	FOR /F "usebackq delims=" %%A IN (`scoop prefix scoop`) DO (
		IF "%%~A"=="%LOCALAPPDATA%\Programs\scoop\apps\scoop\current" (
			SET "scoopRoot=%LOCALAPPDATA%\Programs\scoop"
		) ELSE (
			ECHO Scoop is not installed in "%LocalAppData%\Programs\scoop"
			CALL :getScoopDirFromPrefix "%%~dpA"
		)
	)
)
(
	FOR /D %%A IN ("%~dp0*.*") DO MKLINK /J "%LOCALAPPDATA%\Programs\Total Commander\%%~nxA" "%%~fA"

	CALL :Link "%~dp0bin\7zG.exe" ^
		   "%scoopRoot%\apps\7zip\current\7zG.exe" ^
		   "%LocalAppData%\Programs\7-Zip\7zG.exe"
		   "%ProgramFiles%\7-Zip\7zG.exe"

	MKLINK /J "%~dp0PlugIns\wcx\Total7zip\64" "%scoopRoot%\apps\7zip\current"

	MKLINK /J "%~dp0PlugIns\wcx\Total7zip\Lang" "%scoopRoot%\apps\7zip\current\Lang"

	CALL :Link "%~dp0bin\AutoHotkey.exe" "%ahkPath%"
	CALL :Link "%~dp0bin\AutoHotkeyU64.exe" "%ahkPath%"
EXIT /B
)
:Link <linkPath> <targetPath> <targetPath2> <targetPath3> ...
(
	IF EXIST %2 MKLINK %1 %2 || MKLINK /H %1 %2 & EXIT /B
	IF "%~3"=="" EXIT /B 1
	SHIFT /2
	GOTO :Link
)
:FindAutoHotkeyPath
(
	FOR %%A IN ("%scoopRoot%\apps\autohotkey\current\AutoHotkeyU64.exe" ^
		    "%LocalAppData%\Programs\AutoHotkey\AutoHotkeyU64.exe" ^
		    "%ProgramFiles%\AutoHotkey\AutoHotkeyU64.exe" ^
	           ) DO IF EXIST %%A SET ahkPath=%%A & EXIT /B 0
	EXIT /B 1
)
:getScoopDirFromPrefix <scoopPrefix>
@SETLOCAL
@REM 1 = scoop\apps\scoop\current
@CALL :getDir dirUp "%~1" & REM dirUp = scoop\apps\scoop\
@CALL :getDir dirUp "%dirUp:~0,-1%" & REM dirUp = scoop\apps\
@CALL :getDir dirUp "%dirUp:~0,-1%" & REM %dirUp% = scoop\
(
	ENDLOCAL
	SET "scoopRoot=%dirUp:~0,-1%"
EXIT /B
)
:getDir
(
	SET "%~1=%~dp2"
EXIT /B
)
