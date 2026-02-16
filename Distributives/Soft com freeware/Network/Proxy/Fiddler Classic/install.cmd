@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    IF "%~1"=="" (
        "%~dp0fiddlersetup.exe" /S
    ) ELSE (
        "%~dp0fiddlersetup.exe" /S /D%~1
        rem /Dpath without quotes, must be last argument
    )
)
