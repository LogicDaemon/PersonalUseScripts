@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
IF NOT EXIST "%USERPROFILE%\.cache\gpt4all" IF EXIST "d:\Users\LogicDaemon\GPT4All\Models" MKLINK /J "%USERPROFILE%\.cache\gpt4all" "d:\Users\LogicDaemon\GPT4All\Models"
"%LocalAppData%\Programs\gpt4all_cli\.venv\Scripts\python.exe" "%LocalAppData%\Programs\gpt4all_cli\app.py" %*
)
