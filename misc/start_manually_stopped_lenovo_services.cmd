@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
)

sc start UDCService
sc start LenovoVantageService
rem Lenovo Whisper Mode Service
sc start LenovoWMService
