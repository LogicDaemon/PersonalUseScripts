@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
	IF "%~1"=="*" GOTO :scan
	IF "%~1"=="" GOTO :scan
	smartctl %*
)
:again
@(
	smartctl -a %*|grep -B 5 -A 23 -F "Self-test execution status:"
	PING -n 15 127.0.0.1 >NUL
GOTO :again
)
:scan
@(
	FOR /F "usebackq tokens=1,2,3,4*" %%A IN (`smartctl --scan`) DO START "%%~E" %comspec% /C ""%~dp0" %%A %%B %%C -t short"
	EXIT /B
)
rem >smartctl --scan
rem /dev/sda -d scsi # /dev/sda, SCSI device
rem /dev/sdb -d scsi # /dev/sdb, SCSI device
rem /dev/sdc -d sat # /dev/sdc [SAT], ATA device
rem /dev/sdd -d sat # /dev/sdd [SAT], ATA device
rem /dev/sde -d sat # /dev/sde [SAT], ATA device
rem %%A      B  C   D E-------------------------
