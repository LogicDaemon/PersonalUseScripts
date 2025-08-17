@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

IF NOT EXIST "%~dp0.venv\Scripts\activate.bat" (
    py -m venv "%~dp0.venv" || EXIT /B 1
)
CALL "%~dp0.venv\Scripts\activate.bat"
pip install --require-venv --upgrade --requirement "%~dp0requirements.txt"
python "%~dp0download_latest.py"
)
