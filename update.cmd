@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
FOR /F "usebackq delims=" %%A IN (`hostname`) DO @(
    CALL "%~dpn0@%%~A%~x0"
    EXIT /B
)
EXIT /B 1
)
