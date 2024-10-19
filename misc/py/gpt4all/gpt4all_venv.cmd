@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
IF NOT EXIST "%~dp0.venv" START "" /B /WAIT py -m venv "%~dp0.venv"
CALL "%~dp0.venv\Scripts\activate.bat"
START "" /B /WAIT pip install gpt4all typer
CURL -RL -ogpt4all_app.py https://raw.githubusercontent.com/nomic-ai/gpt4all/main/gpt4all-bindings/cli/app.py
)
