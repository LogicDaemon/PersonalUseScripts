@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

msiexec.exe /qn /norestart /i "%~dp0AWSCLIV2.msi"
IF ERRORLEVEL 1 GOTO :EchoError
EXIT /B
)
:EchoError
@(
    ECHO Error %ERRORLEVEL% installing
    EXIT /B
)
