@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
IF NOT EXIST .venv-gpt4all START "" /B /WAIT py -m venv .venv-gpt4all
CALL .venv-gpt4all\Scripts\activate.bat
START "" /B /WAIT pip install gpt4all typer
CURL -RL -ogpt4all_app.py https://raw.githubusercontent.com/nomic-ai/gpt4all/main/gpt4all-bindings/cli/app.py
)
