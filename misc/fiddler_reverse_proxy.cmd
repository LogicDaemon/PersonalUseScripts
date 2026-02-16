@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

	IF "%~1"=="" (
		REG DELETE HKEY_CURRENT_USER\SOFTWARE\Microsoft\Fiddler2 /v ReverseProxyForPort /f
	) ELSE (
		REG ADD HKEY_CURRENT_USER\SOFTWARE\Microsoft\Fiddler2 /t REG_DWORD /v ReverseProxyForPort /d %1 /f
	)
)
