@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
IF DEFINED VIRTUAL_ENV (
    python.exe %*
    EXIT /B
)
IF EXIST "%LocalAppData%\Programs\Python\Launcher\py.exe" (
    "%LocalAppData%\Programs\Python\Launcher\py.exe" %*
    EXIT /B
)
SET "args=%*"
CALL "%~dp0py_version.cmd" Python* python.exe
)
