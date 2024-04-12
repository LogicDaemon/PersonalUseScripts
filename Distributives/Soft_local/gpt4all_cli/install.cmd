@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
IF NOT EXIST .venv START "" /B /WAIT py -m venv .venv
CALL .venv\Scripts\activate.bat
START "" /B /WAIT pip install gpt4all typer
CURL -RL -oapp.py https://raw.githubusercontent.com/nomic-ai/gpt4all/main/gpt4all-bindings/cli/app.py
)
