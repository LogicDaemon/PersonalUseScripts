@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

sc config UDCService start= demand
sc stop UDCService
sc config LenovoVantageService start= demand
sc stop LenovoVantageService
rem Lenovo Whisper Mode Service
sc config LenovoWMService start= demand
sc stop LenovoWMService
)
