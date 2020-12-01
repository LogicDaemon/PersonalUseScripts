@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
SETLOCAL ENABLEEXTENSIONS

    FOR /F "usebackq skip=1 tokens=1" %%D IN (`%SystemRoot%\System32\Wbem\wmic.exe logicaldisk where "( DriveType=6 Or DriveType=3 )" get Caption`) DO CALL :CheckDrive "%%~D"
EXIT /B
    rem MediaTypes:
    rem Removable media other than floppy (11)
    rem Fixed hard disk media (12)
    
    rem DriveTypes:
    rem Unknown (0)
    rem No Root Directory (1)
    rem Removable Disk (2)
    rem Local Disk (3)
    rem Network Drive (4)
    rem Compact Disc (5)
    rem RAM Disk (6)

    REM https://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
)
:CheckDrive
(
    IF NOT "%~1"=="" (
	FOR /F "usebackq delims=" %%I IN ("%~dp0tempfiles.txt") DO IF NOT EXIST "%~1\%%~I" (
	    ECHO File not exist: "%~1\%%~I", skipping %~1
	    EXIT /B
	)
	ECHO Full match for %~1, cleaning up
	FOR /F "usebackq" %%I IN ("%~dp0tempfiles.txt") DO ECHO N|DEL "%~1\%%~I"
    )
EXIT /B
)
