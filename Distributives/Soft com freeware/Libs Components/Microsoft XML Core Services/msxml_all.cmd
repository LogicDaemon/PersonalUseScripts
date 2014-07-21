@ECHO OFF

REM "%~dp0msxml4-KB925672-enu.exe" /q /norestart
REM msiexec.exe /q /norestart /i "%~dp0msxml6.msi"

"%~dp0msxml4-KB954430-enu.exe" /q /norestart
"%~dp0msxml6-KB954459-enu-x86.exe" /q /norestart
START "" /WAIT /B /D"%~dp0\Updates" %comspec% /C WU_cat_auto.cmd

