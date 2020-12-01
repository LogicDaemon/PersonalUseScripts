@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"
IF NOT DEFINED PROGRAMDATA SET "PROGRAMDATA=%ALLUSERSPROFILE%\Application Data"
IF NOT DEFINED APPDATA IF EXIST "%USERPROFILE%\Application Data" SET "APPDATA=%USERPROFILE%\Application Data"
    
    SET "dirData=%~dp0"
    SET "dirDist=%~dp0"
    SET "dirDlTmp=%~dp0temp\"
    SET "installOptns=/A1H0L1M0G0D0U1K0" & REM https://www.ghisler.ch/wiki/index.php?title=How_to_make_installation_fully_automatic%3F
    SET "dlcmdPrefix=curl.exe -OJLR"
    SET "dlcmdSuffix= || EXIT /B"
    
    FOR /F "usebackq skip=3" %%A IN (`"%SystemRoot%\System32\nslookup.exe -type=txt releaseversion.ghisler.com"`) DO IF NOT "%%~A"=="" SET "newtcver=%%~A"
    IF NOT DEFINED newtcver EXIT /B 1
    FOR /F "usebackq delims=" %%A IN ("%dirData%oldver.txt") DO SET "oldtcver=%%~A"
)
(
    IF "%newtcver%"=="%oldtcver%" EXIT /B 0
    (ECHO %newtcver%)>"%dirData%newver.txt"
    
    FOR /F "delims=.; tokens=1,2,3,4,5" %%A IN ("%newtcver%") DO (
	SET "verComponent1=%%~A"
	SET "verComponent2=%%~B"
	SET "verComponent3=%%~C"
	SET "verComponent4=%%~D"
	SET "verComponent5=%%~E"
    )
)
(
    MKDIR "%dirDlTmp%"
    rem %dlcmdPrefix% http://totalcommander.ch/win/tcmd%verComponent2%%verComponent3%x32.exe %dlcmdSuffix%
    rem %dlcmdPrefix% http://totalcommander.ch/win/tcmd%verComponent2%%verComponent3%x64.exe %dlcmdSuffix%
    START "" /B /WAIT /D "%dirDlTmp%" %dlcmdPrefix% http://totalcommander.ch/win/tcmd%verComponent2%%verComponent3%x32_64.exe %dlcmdSuffix%
    FOR %%A IN ("%dirDlTmp%\*.*") DO (
	MOVE /Y "%%~A" "%dirDist%"
	"%dirDist%\%%~nxA" %installOptns%
    )
    
    MOVE "%dirData%newver.txt" "%dirData%oldver.txt"
    EXIT /B
)
