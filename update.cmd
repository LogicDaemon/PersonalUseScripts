@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
FOR /F "usebackq delims=" %%A IN (`hostname`) DO (
    CALL "%~dpn0@%%~A%~x0" %*
    EXIT /B
)
EXIT /B 1
)
