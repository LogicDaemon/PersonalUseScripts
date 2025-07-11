@(REM coding:CP866
REM 7z-am main file
REM 
REM Theese scripts
REM run 7z with different arguments to gain maximum compression,
REM then compare results'size, deleting all but one smallest,
REM and test the last one at end.
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ECHO OFF
SETLOCAL ENABLEEXTENSIONS
rem ENABLEDELAYEDEXPANSION
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"

IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "OS64Bit=1"
IF DEFINED PROCESSOR_ARCHITEW6432 SET "OS64Bit=1"

REM Setting defaults
IF NOT DEFINED leaveSmallestOnly SET "leaveSmallestOnly=1"
IF NOT DEFINED deleteAfter SET "deleteAfter=0"
IF NOT DEFINED smallestNoSuffix SET "smallestNoSuffix=0"
REM 82 bytes is size of 7z archive containing 1 empty folder
IF NOT DEFINED minArcSize SET "minArcSize=82"
REM   compression parameters and methods defaults
CALL "%~dp07z_get_switches.cmd"

IF NOT DEFINED exe7z CALL find7zexe.cmd
IF NOT DEFINED exe7z (
    IF DEFINED OS64Bit IF EXIST "%~dp0..\PlugIns\wcx\Total7zip\64\7zG.exe" ( SET exe7z="%~dp0..\PlugIns\wcx\Total7zip\64\7zG.exe" ) ELSE IF EXIST "%~dp0..\PlugIns\wcx\Total7zip\64\7z.exe" ( SET exe7z="%~dp0..\PlugIns\wcx\Total7zip\64\7z.exe" )
    IF NOT DEFINED exe7z IF EXIST "%~dp0..\PlugIns\wcx\Total7zip\7zG.exe" ( SET exe7z="%~dp0..\PlugIns\wcx\Total7zip\7zG.exe" ) ELSE IF EXIST "%~dp0..\PlugIns\wcx\Total7zip\7z.exe" ( SET exe7z="%~dp0..\PlugIns\wcx\Total7zip\7z.exe" ) ELSE SET exe7z="7z.exe"
)

SET "switch_DELETEAFTER_VarName=deleteAfter"
SET "switch_DA_VarName=deleteAfter"
SET "switch_SMALLESTNOSUFFIX_VarName=smallestNoSuffix"
SET "switch_LEASTNOSUFFIX_VarName=smallestNoSuffix"
SET "switch_SNS_VarName=smallestNoSuffix"

SET "switch_LEAVEALL_VarName=leaveSmallestOnly"
SET "switch_LEAVEALL_invert=1"
SET "switch_LA_VarName=leaveSmallestOnly"
SET "switch_LA_invert=1"
)
:checkSwitch
SET "curSwitch=%~1"
(
	REM -- - stop switches processing
	IF "%curSwitch:~0,2%" EQU "--" GOTO :endcycle
	REM if first symbol is - or / then this is switch
	SET "curSwitch=%curSwitch:~1%"
	IF "%curSwitch:~0,1%" EQU "/" GOTO :processSwitch
	IF "%curSwitch:~0,1%" EQU "-" GOTO :processSwitch
	REM else this is pathname
GOTO :next
)
:processSwitch
(
	REM assume negative modificator ("NO" or "N") is used
	IF DEFINED switch_%curSwitch:~2%_VarName IF "%curSwitch:~0,2%" EQU "NO" (
		REM without comma, :~ returns till end of string
		SET "curSwitch=%curSwitch:~2%"
		SET "switchMeaning=0"
	)
	IF NOT DEFINED switchMeaning IF DEFINED switch_%curSwitch:~1%_VarName IF "%curSwitch:~0,1%" EQU "N" (
		SET "curSwitch=%curSwitch:~1%"
		SET "switchMeaning=0"
	)
	REM negative modificator is not actually used
	IF NOT DEFINED switchMeaning SET "switchMeaning=1"
	IF DEFINED switch_%curSwitch%_VarName GOTO :setVarBySwitch
	IF DEFINED z7zusedeflt%curSwitch% GOTO :set7zModeBySwitch
)
:next
PUSHD "%~1" && (
	CALL :processPath Dir "%~f1"
	POPD
	REM POPD does not change errorlevel
	IF NOT ERRORLEVEL 1 IF "%deleteAfter%"=="1" RD /S /Q "%~f1"
	GOTO :endcycle
)
:notADirectory
(
	CALL :processPath File "%~1"
	IF NOT ERRORLEVEL 1 IF NOT "%~x1"==".7z" IF "%deleteAfter%"=="1" DEL "%~1"
	@REM GOTO :endcycle
)
:endcycle
(
	REM exit if no more arguments
	IF "%~2"=="" EXIT /B
	REM there are, process them
	SHIFT
GOTO :next
)
:processPath
(
	SET "archiveslist="
	FOR /F "usebackq delims== tokens=1*" %%I IN (`set z7zusedeflt`) DO (
	ECHO %%I=%%J
		IF "%%J"=="1" (
		SET "z7zmethodVar=%%~I" && CALL :SetArchivingParameters %2 || EXIT /B
		CALL :run7z%~1 %2 || (ECHO %exe7z% returned error.&EXIT /B)
		)
	)
)
IF "%leaveSmallestOnly%"=="1" CALL :leaveSmallestOnlyTestsmallest %archiveslist%
(
	REM "%smallest%" modified in :leaveSmallestOnlyTestsmallest
	IF "%smallestNoSuffix%"=="1" CALL :renameNoSuffix "%smallest%"
	EXIT /B
)
:SetArchivingParameters
SET "arcname=%~1"
(
	IF "%arcname:~-1%"=="\" SET "arcname=%arcname:~0,-1%"
	REM without comma, :~ returns till end of string
	SET "z7zmethodName=%z7zmethodVar:~11%"
)
(
	FOR /F "usebackq delims== tokens=1*" %%I IN (`SET "z7zSwitches%z7zmethodName%"`) DO (
		ECHO Method: "%z7zmethodVar:~11%", var: "%%I", switches: "%%J"
		SET "z7zSwitches=%%J"
		EXIT /B
	)
	ECHO Failed to get archiving parameters %2 for %1
	EXIT /B 1
)
:run7zDir
(
	ECHO %exe7z% a -r %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z"
	START "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /BELOWNORMAL /B /WAIT %exe7z% a -r %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z"
	SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B
)
:run7zFile
(
	ECHO %exe7z% a %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z" %1
	START "Compressing [%z7zmethodName%] to %arcname%.%z7zmethodName%.7z" /BELOWNORMAL /B /WAIT %exe7z% a %z7zSwitches% -- "%arcname%.%z7zmethodName%.7z" "%~1"
	SET archiveslist=%archiveslist% "%arcname%.%z7zmethodName%.7z"
EXIT /B
)
:leaveSmallestOnlyTestsmallest
(
	REM takes list of archive files as arguments
	REM compares them by size
	REM and deletes bigger
	REM Then tests (%exe7z% t) smallest left over
	SET "smallest=%~1"
	CALL :GetSize smallestsize "%~1" || (ECHO Something wrong, terminating deletion.& EXIT /B)
)
:leaveSmallest_next
(
	REM first check if there are any concurrents left
	IF "%~2" EQU "" (
		ECHO Finished deleting bigger archives, testing last one left.
		START "Testing %smallest%" /BELOWNORMAL /B /WAIT %exe7z% t -- "%smallest%"
		EXIT /B
	)
	CALL :GetSize concurrentsize "%~2" || (ECHO Something wrong, terminating deletion.& EXIT /B)
	SHIFT
)
(
	IF %smallestsize% GTR %concurrentsize% (
		ECHO Deleting "%smallest%" because it is bigger than "%~1"
		DEL "%smallest%"
		SET "smallest=%~1"
		SET "smallestsize=%concurrentsize%"
	) ELSE (
		ECHO Deleting "%~1" because it is bigger than "%smallest%"
		DEL "%~1"
	)
GOTO :leaveSmallest_next
)
:set7zModeBySwitch
(
	SET "z7zusedeflt%curSwitch%=%switchMeaning%"
GOTO :nextSwitch
)
:setVarBySwitch
(
	SETLOCAL ENABLEDELAYEDEXPANSION
	SET "destVar=!switch_%curSwitch%_VarName!"
)
(
	ENDLOCAL
	IF DEFINED switch_%curSwitch%_invert (
		SET /A "%destVar%=1-%switchMeaning%"
	) ELSE (
		SET "%destVar%=%switchMeaning%"
	)
GOTO :nextSwitch
)
:nextSwitch
(
	SHIFT
	GOTO :checkSwitch
)
:renameNoSuffix
(
	REN "%~1" *.
	REN "%~dpn1" "*%~x1"
EXIT /B
)
:GetSize <varname> <path>
(
	SETLOCAL
	IF NOT EXIST "%~2" (ECHO File "%~2" not found.& EXIT /B 2)
	SET "size="
	FOR %%I IN ("%~2") DO (
		IF DEFINED size (ECHO Multiple files found for path "%~2".& EXIT /B 1)
		IF %%~zI LSS %minArcSize% (ECHO File "%~2" size is %%~zI bytes. Must be at least %minArcSize%.& EXIT /B 1)
		SET "size=%%~zI"
	)
	REM Check if file found and size is set
	IF NOT DEFINED size (ECHO File "%~2" size cannot be determined.& EXIT /B 2)
)
(
	ENDLOCAL
	SET "%~1=%size%"
EXIT /B
)
