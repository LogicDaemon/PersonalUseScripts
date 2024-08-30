@(REM coding:CP866
    SETLOCAL ENABLEEXTENSIONS
    IF DEFINED VIRTUAL_ENV (
        pip.exe %*
        EXIT /B
    )
    IF EXIST "%LocalAppData%\Programs\Python\Launcher\py.exe" (
        "%LocalAppData%\Programs\Python\Launcher\py.exe" -m pip %*
        EXIT /B
    )
    CALL "%~dp0py.cmd" -m pip %*
)
