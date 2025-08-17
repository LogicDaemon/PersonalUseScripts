@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

IF NOT EXIST %TEMP%\set_older_datetimes_for_same_files.venv py -m venv "%TEMP%\set_older_datetimes_for_same_files.venv"
CALL "%TEMP%\set_older_datetimes_for_same_files.venv\Scripts\activate.bat"
"%TEMP%\set_older_datetimes_for_same_files.venv\Scripts\pip.exe" install --require-venv --upgrade --requirement "%LocalAppData%\Scripts\py\set_older_datetimes_for_same_files-requirements.txt"
"%TEMP%\set_older_datetimes_for_same_files.venv\Scripts\python.exe" "%LocalAppData%\Scripts\py\set_older_datetimes_for_same_files.py" "%~dp0." v:\Distributives
)
