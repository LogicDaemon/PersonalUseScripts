REM coding:OEM

REM InstallMode 1 means Plugin Only
REM InstallMode 0 means both ActiveX and Plugin

SET SetSystemSettings=0

IF EXIST "%SystemRoot%\system32\Macromed\Flash\" (
    SET InstallMode=0
) ELSE (
    SET InstallMode=1
)

CALL "%~dp0install.cmd" %InstallMode%
