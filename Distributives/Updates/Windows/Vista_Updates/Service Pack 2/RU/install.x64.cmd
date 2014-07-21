@REM coding:OEM
SET /P Restart=Restart after install?
SET lastarg=/promptrestart
IF "%Restart%"=="1" SET lastarg=/warnrestart:300
IF "%Restart%"=="0" SET lastarg=/norestart

START "" "%~dp0Windows6.0-KB948465-X64.exe" /unattend %lastarg%

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
