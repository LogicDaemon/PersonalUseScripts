@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
SET s=
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET "s=64"
IF DEFINED PROCESSOR_ARCHITEW6432 SET "s=64"
SET "d=%LOCALAPPDATA%\Programs\SysInternals"
SET "up=https://live.sysinternals.com/%~n0"
)
@SET "p=%d%\%~n0"
@SET "f=%p%%s%"
@SET "fe=%f%.exe"
@(
IF NOT EXIST "%d%" MKDIR "%d%"
IF EXIST "%fe%.bak" DEL "%fe%.bak"
CURL -R -o "%p%.chm" -z "%p%.chm" %up%.chm
CURL -R -o "%fe%.new" -z "%fe%" %up%%s%.exe
FOR %%A IN ("%fe%.new") DO @(
IF EXIST "%%~A" IF %%~zA GTR 300000 (
MOVE /Y "%%~A" "%fe%" || (
MOVE /Y "%fe%" "%fe%.bak" && movefile "%fe%.bak" ""
MOVE /Y "%%~A" "%fe%"
) || MOVE /Y "%fe%.bak" "%fe%" ) )
ENDLOCAL
"%fe%" %*
)
