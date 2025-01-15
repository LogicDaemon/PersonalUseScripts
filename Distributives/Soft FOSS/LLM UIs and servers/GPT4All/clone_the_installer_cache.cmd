@(REM coding:CP866
REM ;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
    PUSHD "%TEMP%"
)
:again
@(
    ln -q -r cache cache_
GOTO :again
)
