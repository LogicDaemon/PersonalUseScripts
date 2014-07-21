@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

FOR /D %%I IN (%~dp0*) DO CALL :InstallUpdatesFromDir "%%~I"

EXIT /B

:InstallUpdatesFromDir
SET switches=-u -n -z
IF EXIST "%~1\switches.txt" FOR /F "usebackq delims=" %%J IN ("%~1\switches.txt") DO SET switches=%%J
FOR %%J IN ("%~1\*.exe") DO %%J %switches%
EXIT /B
