@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
IF "%~2"=="" EXIT /B 1
    FOR /F "usebackq delims=" %%A IN (`DIR /B /AD /O-D "%LOCALAPPDATA%\Programs\py\%~1"`) DO @(
        IF EXIST "%LOCALAPPDATA%\Programs\py\%%~A\%~2" (
            "%LOCALAPPDATA%\Programs\py\%%~A\%~2" %args%
            EXIT /B
        )
    )
)

rem             SET "PYTHONHOME=%LOCALAPPDATA%\Programs\py\%%~A"
rem             IF EXIST "%LOCALAPPDATA%\Programs\py\%%~A\lib" (
rem                 SET "PYTHONPATH=%LOCALAPPDATA%\Programs\py\%%~A\lib;%PYTHONPATH%"
rem             ) ELSE (
rem                 SET "foundlibdir="
rem                 FOR /F "usebackq delims=" %%B IN (`DIR /B /AD /O-D "%LOCALAPPDATA%\Programs\py\*"`) DO @IF NOT DEFINED foundlibdir IF EXIST "%LOCALAPPDATA%\Programs\py\%%~B\lib" SET "foundlibdir=1" & SET "PYTHONPATH=%LOCALAPPDATA%\Programs\py\%%~B\lib;%PYTHONPATH%"
rem             )
rem             SET "PATH=%LOCALAPPDATA%\Programs\py\%%~A;%PATH%" 
