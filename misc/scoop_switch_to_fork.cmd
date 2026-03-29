@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

FOR /F "usebackq delims=" %%A IN (`scoop prefix scoop`) DO CD /D "%%~A"
git remote add fork https://github.com/LogicDaemon/Scoop.git
git fetch fork
git checkout --no-track -B master fork/master
)
