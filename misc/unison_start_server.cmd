@(REM coding:CP866
	IF NOT DEFINED hostname CALL :ReadRegHostname hostname
	IF NOT DEFINED unisontext CALL _unison_get_command.cmd || @(
		ECHO Need _unison_get_command.cmd to determine console unison executable path
		EXIT /B
	) >&2
	IF "%~1"=="" (
		IF NOT DEFINED unisonopt SET unisonopt=-auto
	) ELSE (
		SET "unisonopt=%unisonopt% %*"
	)

	IF NOT DEFINED unisonPort SET /A "unisonPort=%RANDOM%/2+16384"
)
SET "unisonServer=socket://localhost:%unisonPort%/"
(
PUSHD "%TEMP%" || EXIT /B
START "Distributives Unison server" /MIN %unisontext% -socket "%unisonPort%"
PING -n 2 127.0.0.1 >NUL
EXIT /B
)
:ReadRegHostname <var>
(
FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "%~1=%%~J"
EXIT /B
)
