@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
SET "args=%*"
CALL "%~dp0py_version.cmd" pypy2.* pypy.exe
)
