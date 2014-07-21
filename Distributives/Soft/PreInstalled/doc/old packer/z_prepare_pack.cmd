@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
@ECHO OFF

SET Switches=-mx=9 -m0=BCJ2 -m1=LZMA:a=2:d24:fb=255:lc=4 -m2=LZMA:d21 -m3=LZMA:d21 -mb0:1 -mb0s1:2 -mb0s2:3
IF "%OutputDir%"=="" SET OutputDir=%~dp0new
IF NOT EXIST "%OutputDir%" MKDIR "%OutputDir%"

IF "%~1"=="" CALL :startpack "%CD%"

:cycle
IF "%~1"=="" GOTO :EOF
CALL :startpack %1
SHIFT
GOTO cycle

:startpack
@ECHO ON
SET packpath=%~dp1
SET arcname=%~nx1
PAUSE

ECHO packing %arcname%
IF EXIST "%OutputDir%\%arcname%.bak.7z" DEL "%OutputDir%\%arcname%.bak.7z"
IF EXIST "%OutputDir%\%arcname%.7z" REN "%OutputDir%\%arcname%.7z" "%arcname%.bak.7z"
rem Title Packing %arcname%
IF "%packpath%"=="" (
    start "Packing %arcname%" /wait /B /belownormal 7z a %Switches% "%OutputDir%\%arcname%.7z"
) else (
    start "Packing %arcname%" /wait /B /D "%packpath%" /belownormal 7z a %Switches% "%OutputDir%\%arcname%.7z"
)
IF ERRORLEVEL 1 PAUSE !!! ERROR : to Stop, press Ctrl+Break, any other key to continue
Del "%OutputDir%\%arcname%.bak.7z"
