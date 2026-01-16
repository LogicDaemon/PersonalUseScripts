@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
)

FOR %%A IN ( ^
		ACCSvc ^
		DtsApo4Service ^
	) DO @(
	sc config "%%~A" start= demand
	sc stop "%%~A"
)
