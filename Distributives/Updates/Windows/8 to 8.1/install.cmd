@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
SETLOCAL ENABLEEXTENSIONS

SET suffix=x86
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET suffix=x64
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET suffix=x64

SET wusa=wusa.exe
IF EXIST "%SystemRoot%\System32\wusa.exe" SET wusa="%SystemRoot%\System32\wusa.exe"
IF EXIST "%SystemRoot%\SysNative\wusa.exe" SET wusa="%SystemRoot%\SysNative\wusa.exe"
)
(
%wusa% "\\Srv0\Distributives\Updates\Windows\8\Win8 to Win8.1\Windows8-RT-KB2871389-%suffix%.msu" /quiet /norestart 
%wusa% "\\Srv0\Distributives\Updates\Windows\8\Win8 to Win8.1\Windows8-RT-KB2917499-%suffix%.msu" /quiet /norestart 
)
