@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
@rem По идее, эта хрень должна принимать 1 параметр - имя папки или файла и архивировать его в %OutputDir% или стартовую папку, если %OutputDir% не задан
@ECHO Off

:cycle
IF "%~1"=="" GOTO :EOF
CALL :startpack %1
SHIFT
GOTO cycle

:startpack
IF "%OutputDir%"=="" SET OutputDir=%~dp0
SET archname=%~nx1
SET Switches=-mx=9 -m0=BCJ2 -m1=LZMA:a=2:d24:fb=255:lc=4 -m2=LZMA:d21 -m3=LZMA:d21 -mb0:1 -mb0s1:2 -mb0s2:3

ECHO packing %archname%
IF EXIST "%OutputDir%\%archname%.bak.7z" DEL "%OutputDir%\%archname%.bak.7z"
IF EXIST "%OutputDir%\%archname%.7z" REN "%OutputDir%\%archname%.7z" "%archname%.bak.7z"
TITLE Packing %archname%
nice 7z a %Switches% "%OutputDir%\%archname%.7z" "%~1"||PAUSE ERROR : to Stop, press Ctrl+Break, any other key to continue
DEL "%OutputDir%\%archname%.bak.7z"
