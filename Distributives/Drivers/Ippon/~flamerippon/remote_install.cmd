@REM coding:OEM

MKDIR "\\%1\Admin$\Temp\~flamerippon\"
xcopy /Y "%~dp0*.*" "\\%1\Admin$\Temp\~flamerippon\"
psexec \\%1 cmd.exe /U /C "%SystemRoot%\Temp\~flamerippon\install.cmd"
RD /S /Q "\\%1\Admin$\Temp\~flamerippon\"
