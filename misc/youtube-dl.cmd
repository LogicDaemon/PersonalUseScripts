@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem SET "PYTHONPATH=%LocalAppData%\Programs\youtube-dl\build\lib;%PYTHONPATH%"
rem SET "PATH=%LocalAppData%\Programs\youtube-dl\build\Lib;%PATH%"
rem CALL "%~dp0py.cmd" "%LocalAppData%\Programs\youtube-dl\build\youtube-dl.py" %*
)
"%LocalAppData%\Programs\Python\Python311\Scripts\youtube-dl.exe" %*
