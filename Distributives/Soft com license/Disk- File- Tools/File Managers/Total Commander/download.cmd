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
    SET "dlcmdPrefix=curl.exe -OJLR"
    SET "dlcmdSuffix= || EXIT /B"
    
    FOR /F "usebackq skip=3" %%A IN (`"%SystemRoot%\System32\nslookup.exe -type=txt releaseversion.ghisler.com"`) DO IF NOT "%%~A"=="" SET "newtcver=%%~A"
    IF NOT DEFINED newtcver EXIT /B 1
    FOR /F "usebackq delims=" %%A IN ("%dirData%lastver.txt") DO SET "oldtcver=%%~A"
)
(
    IF "%newtcver%"=="%oldtcver%" (
        ECHO Downloaded version is the same as the current one, %newtcver%
        EXIT /B 0
    )
    (ECHO %newtcver%)>"%dirData%newver.txt"
    
    FOR /F "delims=.; tokens=1,2,3,4,5" %%A IN ("%newtcver%") DO (
	SET "verComponent1=%%~A"
	SET "verComponent2=%%~B"
	SET "verComponent3=0%%~C"
	SET "verComponent4=%%~D"
	SET "verComponent5=%%~E"
    )
)
(
    SET "verComponent3=%verComponent3:~-2%"
    IF "%verComponent4%"=="0" SET "verComponent4="
)
(
    MKDIR "%dirDlTmp%"
    PUSHD "%dirDlTmp%" || EXIT /B
    %dlcmdPrefix% https://totalcommander.ch/%verComponent2%%verComponent3%%verComponent4%/tcmd%verComponent2%%verComponent3%%verComponent4%x32.exe %dlcmdSuffix% || EXIT /B
    %dlcmdPrefix% https://totalcommander.ch/%verComponent2%%verComponent3%%verComponent4%/tcmd%verComponent2%%verComponent3%%verComponent4%x64.exe %dlcmdSuffix% || EXIT /B
    %dlcmdPrefix% https://totalcommander.ch/%verComponent2%%verComponent3%%verComponent4%/tcmd%verComponent2%%verComponent3%%verComponent4%x32_64.exe %dlcmdSuffix% || EXIT /B
    POPD || EXIT /B
    FOR %%A IN ("%dirDlTmp%\*.*") DO MOVE /Y "%%~A" "%dirDist%" || EXIT /B
    
    MOVE /Y "%dirData%newver.txt" "%dirData%lastver.txt"
    EXIT /B
)
