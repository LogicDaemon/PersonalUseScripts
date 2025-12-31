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
    IF EXIST "%LocalAppData%\Programs\scoop\apps\python\current\python.exe" (
        "%LocalAppData%\Programs\scoop\apps\python\current\python.exe" %*
        EXIT /B
    )
    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-D "%LOCALAPPDATA%\Programs\Python\%~1"`) DO @IF EXIST "%LOCALAPPDATA%\Programs\Python\%%~A\python.exe" (
        SET "pythonPath="%LOCALAPPDATA%\Programs\Python\%%~A\python.exe"
        GOTO :found
    )
    SET pythonPath=python
)
:found
"%pythonPath%" %*
