@REM coding:OEM

CALL "%~dp0Update_Unattended.cmd" /autoreboot %*

PING 127.0.0.1 -n 3>NUL
SHUTDOWN /R /T 300

