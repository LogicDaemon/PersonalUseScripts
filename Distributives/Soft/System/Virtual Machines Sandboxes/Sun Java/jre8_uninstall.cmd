@(REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
IF "%~dp0"=="" (SET "srcpath=%CD%\") ELSE SET "srcpath=%~dp0"

REM http://www.74k.org/java-uninstall-remove-guids-strings

IF "%~1"=="/LeaveLast" SET LeaveLast=1
)
(
IF "%LeaveLast%"=="" msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218074F0} /qn /norestart & REM 8u74
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218073F0} /qn /norestart & REM 8u73
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218072F0} /qn /norestart & REM 8u72
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218071F0} /qn /norestart & REM 8u71
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218066F0} /qn /norestart & REM 8u66
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218060F0} /qn /norestart & REM 8u60
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218051F0} /qn /norestart & REM 8u51
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F83218045F0} /qn /norestart & REM 8u45
msiexec.exe /x {26A24AE4-039D-4CA4-87B4-2F86418040F0} /qn /norestart & REM 8u40
)