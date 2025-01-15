@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

FOR /F "usebackq delims=" %%A IN ("%~dp0tasks.txt") DO SCHTASKS /CHANGE /TN "%%~A" /Disable
)
