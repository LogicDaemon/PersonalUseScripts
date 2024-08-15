@(REM coding:CP866
REM Repacks any archive to 7z
REM usage: %0 [/R path] mask
REM /R path		scan path recursively
REM 			if there is only one arg after /R, it is taken as mask, not as path
REM Accepts masks
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
IF "%~1"=="" (
    ECHO At least one argument required.
    EXIT /B 2
)
IF NOT DEFINED exe7z CALL find7zexe.cmd
SET secondtry=
)
:mktempagain
SET "tempdest=%TEMP%\%~n0_temp%RANDOM%"
IF EXIST "%tempdest%" (
    IF "%secondtry%"=="1" (
	ECHO "%tempdest%" must not exist
	EXIT /B 2
    )
    SET "secondtry=1"
    GOTO :mktempagain
)

:checkArg
IF /I "%~1"=="/R" (
    rem Recursive, with dir if there is more than one argument after; otherwise, it's only mask
    IF "%~3"=="" (
	SET "ArgForFOR=%1 "
    ) ELSE (
	SET "ArgForFOR=%1 %2"
	SHIFT
    )
    GOTO :shiftToNextArg
)
IF /I "%~1"=="/NK" (
    SET "nobackup=1"
    GOTO :shiftToNextArg
)

FOR %ArgForFOR% %%I IN (%1) DO CALL :process "%%~fI"

:shiftToNextArg
(
IF "%~2"=="" EXIT /B
SHIFT
GOTO :checkArg
)
:process
(
    RD /S /Q "%tempdest%"
    %exe7z% x -o"%tempdest%\%~n1" -- "%~1"
    PUSHD "%tempdest%" && (
	CALL "%~dp07z_am.cmd" /DELETEAFTER /LEASTNOSUFFIX "%tempdest%\%~n1" && (
            IF NOT "%nobackup%"=="1" (
                rem FOR %%A IN ("%tempdest%\*.7z") DO CALL :removeSuffix "%%~A"
                FOR %%A IN ("%tempdest%\*.*") DO @IF EXIST "%~dp1%%~nxA" MOVE "%~dp1%%~nxA" "%~dp1%%~nxA.bak"
            )
            MOVE /Y "%tempdest%\*.*" "%~dp1"
	)
	POPD
    )
    RD /S /Q "%tempdest%"
EXIT /B
)
:removeSuffix
@(REM filename is expected to be *.LZMA2.7z or *.LZMA2BCJ2.7z
    SETLOCAL ENABLEEXTENSIONS
    SET "currName=%~n1"
)
@IF       "%currName:~-10%"==".LZMA2BCJ2" ( SET "newName=%currName:~0,-10%"
) ELSE IF "%currName:~-6%"==".LZMA2"      ( SET "newName=%currName:~0,-6%"
)
@(
    ECHO %newName%
    PAUSE
    REN %1 "%newName%%~x1"
EXIT /B
)
