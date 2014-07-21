@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\
IF "%utilsdir%"=="" SET utilsdir=%srcpath%..\utils\

IF DEFINED ProgramFiles(x86) SET ProgramFiles=%ProgramFiles(x86)%
"%utilsdir%7za.exe" x -r -aoa -o"%ProgramFiles%\%~n0" "%srcpath%%~n0.7z"

IF NOT "%RunInteractiveInstalls%"=="0" (
    IF NOT "%SetSystemSettings%"=="0" (
            PUSHD "%ProgramFiles%\%~n0"
            CALL Notepad2-install.cmd
            POPD
        )
    )
)
