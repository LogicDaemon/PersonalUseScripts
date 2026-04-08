@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

python -c "import lxml" || (
	IF NOT EXIST "%~dp0.venv" uv venv "%~dp0.venv"
	CALL "%~dp0.venv\Scripts\activate.bat"
	uv pip install -Ur "latest_python3 requirements.txt"
)
python "%~dp0latest_python3.py" download --pre-download-components --above-version 3.13
)
