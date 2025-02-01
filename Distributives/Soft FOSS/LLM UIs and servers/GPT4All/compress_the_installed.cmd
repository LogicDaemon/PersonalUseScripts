@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

PUSHD "%LOCALAPPDATA%\Programs\gpt4all" || EXIT /B
IF EXIST "%LOCALAPPDATA%\Programs\7-max\7maxc.exe" SET sevenmax="%LOCALAPPDATA%\Programs\7-max\7maxc.exe"

%comspec% /U /C "CHCP 65001 & %sevenmax% zpaq64.exe a "%~dp0installed\gpt4all.zpaq" * -m4 >>"%~dp0installed\gpt4all.zpaq.log" 2>>"%~dp0installed\gpt4all.zpaq.errors.log""
)
