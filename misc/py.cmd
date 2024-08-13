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
    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-D "%LOCALAPPDATA%\Programs\Python\%~1"`) DO @IF EXIST "%LOCALAPPDATA%\Programs\Python\%%~A\python.exe" (
        SET "py_ver=%%~A"
        GOTO :found
    )
    python %*
    EXIT /B 1
)
:found
"%LOCALAPPDATA%\Programs\Python\%%~A\%~2" %*
