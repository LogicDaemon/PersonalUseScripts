@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
FOR /F "USEBACKQ DELIMS=" %%A IN (`DIR /B /A-D /O-D "%~dp0Git-*-64-bit.exe"`) DO (
    "%%~A" /SILENT /NORESTART
    EXIT /B
)
)
