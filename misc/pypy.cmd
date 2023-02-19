@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
SET "args=%*"
CALL "%~dp0py_version.cmd" pypy3.* pypy3.exe
)
