@REM coding:OEM
REM                                     Automated software update scripts
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru

SETLOCAL ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET dlserver=ftp://ftp.opera.com/
SET dlpath=pub/opera/win/
SET findargs=-mindepth 3 -maxdepth 3 -path
SET tempdlpath=%srcpath%temp

SET unxfind=%SystemDrive%\SysUtils\UnxUtils\find.exe

SET distcleanup=1
IF "%~1"=="/skipdlpart" GOTO :skipdlpart

SET excllist=%dlpath%lng
FOR /D %%I IN ("%tempdlpath%\*.*") DO (
    SET excllist=!excllist!,%dlpath%%%~nxI
    REM TODO: не удалять последнюю версию
    REM TODO: не добавлять последнюю версию в список исключений
    RD /S /Q "%%~I"
    MKDIR "%%~I"
)


rem CALL \Scripts\_DistDownload.cmd %dlserver%%dlpath% "*_ru_*.exe" "-m -nH --cut-dirs=3 -np" "-X%excllist%"
CALL \Scripts\_DistDownload.cmd %dlserver%%dlpath% "_" -m -nH --cut-dirs=3 -np -A.i386.autoupdate.exe --no-cache "-X%excllist%"
CALL \Scripts\_DistDownload.cmd %dlserver%%dlpath% "_" -m -nH --cut-dirs=3 -np -A_int_Setup.exe --no-cache "-X%excllist%"
CALL \Scripts\_DistDownload.cmd %dlserver%%dlpath% "_" -m -nH --cut-dirs=3 -np -A_en_Setup.exe --no-cache "-X%excllist%"

rem TODO: не продолжать, если новая версия не выше последней (сначала вышла 1200, затем 1154)

:skipdlpart
CALL :FindAndUpdate autoupdate Opera-*.i386.autoupdate.exe
CALL :FindAndUpdate autoupdate Opera-*.x64.autoupdate.exe
CALL :FindAndUpdate int Opera_*_int_Setup.exe
CALL :FindAndUpdate int Opera_*_int_Setup_x64.exe
CALL :FindAndUpdate en Opera_*_en_Setup.exe
CALL :FindAndUpdate en Opera_*_en_Setup_x64.exe

IF NOT DEFINED SUScripts EXIT /B

REM Now check if distributive filename changed, and so if there is need to update software_update list
SET distrefname=%tempdlpath%\distributives.lst
SET distrefnameprev=%tempdlpath%\distributives.prev.lst

MOVE /Y "%distrefname%" "%distrefnameprev%"
FOR %%I IN ("%srcpath%autoupdate\Opera-*.i386.autoupdate.exe") DO SET distname=%%~nxI
ECHO %distname%>"%distrefname%"

FC /B "%distrefname%" "%distrefnameprev%" >NUL
REM ERRORLEVEL 2 = One of compared files not exist or somethin more serious
IF ERRORLEVEL 2 EXIT /B
REM ERRORLEVEL 1 = compared files differ
IF NOT ERRORLEVEL 1 EXIT /B

CALL "%SUScripts%\..\templates\_add_withVer.cmd" "%distname:~6,-20%"
REM 							 without "Opera-" prefix and ".i386.autoupdate.exe" suffix

EXIT /B
:FindAndUpdate
    SET cleanup_action=CALL mvold
    FOR /F "usebackq delims=" %%I IN (`%unxfind% "%tempdlpath%" %findargs% "*\\%~1\\%~2"`) DO (
	IF EXIST "%srcpath%%~1" (
	    CALL distcleanup "%srcpath%%~1\%~2" "%srcpath%%~1\%%~nxI"
	) ELSE (
	    MKDIR "%srcpath%%~1"
	)
	xln "%%~I" "%srcpath%%~1\%%~nxI"||COPY /B /Y "%%~I" "%srcpath%%~1\%%~nxI"
    )
EXIT /B
