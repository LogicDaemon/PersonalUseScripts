@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

SET "destBase=%LOCALAPPDATA%\Programs\FreeVimager"
FOR /F "usebackq delims=" %%A IN (`DIR /B /O-D "%~dp0FreeVimager-*-Portable.exe"`) DO @(
	SET "srcName=%%~A"
	SET "nameNoExt=%%~nA"
	SET "srcPath=%~dp0%%~A"
	GOTO :unpack
)
EXIT /B 1
)
:unpack
SET "destDir=%destBase%_%nameNoExt:FreeVimager-=%"
(
	MKDIR "%destDir%"
	ECHO N|XCOPY "%srcPath%" "%destDir%\" /G /I /-Y
	RD "%destBase%"
	MKLINK /J "%destBase%" "%destDir%"
	IF NOT EXIST "%destDir%\%nameNoExt%.ini" ECHO.>"%destDir%\%nameNoExt%.ini"
	MKLINK "%destDir%\FreeVimager.ini" "%destDir%\%nameNoExt%.ini"
	MKLINK "%destDir%\FreeVimager.exe" "%destDir%\%srcName%"
)
