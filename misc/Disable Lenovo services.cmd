@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

rem LenovoWMService = Lenovo Whisper Mode Service
FOR %%A IN ( ^
	UDCService ^
	LenovoVantageService ^
	NahimicService ^
	LenovoWMService ^
	LenovoProcessManagement ^
	LenovoFnAndFunctionKeys ^
	logi_lamparray_service ^
	) DO @(
	sc config %%A start= demand
	sc stop %%A
)
)
