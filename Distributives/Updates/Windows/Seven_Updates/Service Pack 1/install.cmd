@REM coding:OEM
SET /P Restart=Restart after install?
SET lastarg=/promptrestart
IF "%Restart%"=="1" SET lastarg=/warnrestart:300
IF "%Restart%"=="0" SET lastarg=/norestart

SET OS64bit=0
IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" SET OS64bit=1
IF /I "%PROCESSOR_ARCHITEW6432%"=="AMD64" SET OS64bit=1

IF "%OS64bit%"=="1" (
    SET "dist=..\..\wsusoffline\w61-x64\glb\windows6.1-KB976932-X64.exe"
) ELSE (
    SET "dist=..\..\wsusoffline\w61\glb\windows6.1-KB976932-X86.exe"
)

FOR %%I IN ("%dist%") DO START "" "%%~I" /unattend %lastarg%

EXIT /B


AVAILABLE SWITCHES:
[/help] [/quiet] [/unattend] [/nodialog] [/norestart] [/forcerestart] [/warnrestart] [/promptrestart] 

/help		Displays this message

SETUP MODES:
/quiet		Quiet mode (no user interaction or display)
/unattend		Unattended mode (progress bar only)
/nodialog		Hide the installation result dialog after completion

RESTART OPTIONS:
/norestart		Do not restart when installation is complete
/forcerestart	Restart after installation
/warnrestart[:<seconds>]	Warn and restart automatically if requir
