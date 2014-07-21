@REM coding:OEM
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 echo Unable to enable extensions
If "%srcpath%"=="" Set srcpath=%~dp0
If "%srcpath%"=="" Set srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF NOT EXIST "%ProgramFiles%\%~n0" MKDIR "%ProgramFiles%\%~n0"
compact /C /S:"%ProgramFiles%\%~n0" /I /Q
"%utilsdir%7za.exe" x -r -aoa "%srcpath%%~n0.7z" -o"%ProgramFiles%\%~n0"
IF "%SetUserSettings%"=="1" (
    PUSHD "%ProgramFiles%\%~n0"
    IF EXIST "%~n0.ini" REN "%~n0.ini" "%~n0.ini.bak"
    COPY /Y /B "%~n0.distributed.ini" "%~n0.ini"
    POPD
)
IF "%SetSystemSettings%"=="1" (
    IF NOT EXIST "%SystemDrive%\Local_Scripts" MKDIR "%SystemDrive%\Local_Scripts"
    ECHO "%programfiles%\%~n0\%~n0.exe">"%SystemDrive%\Local_Scripts\%~n0.cmd"
    "%utilsdir%pathman.exe" /as "%SystemDrive%\Local_Scripts"
)
