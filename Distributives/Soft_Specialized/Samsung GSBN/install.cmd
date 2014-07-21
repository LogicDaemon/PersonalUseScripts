@REM coding:OEM

7z x -y -aoa -o"%TEMP%\SamsungGSBN_Installer" "%~dp0SamsungGSBN_Installer.exe"
COPY /B /Y "%~dp0setup.iss" "%TEMP%\SamsungGSBN_Installer\Disk1\"

PUSHD "%TEMP%\SamsungGSBN_Installer\Disk1\"
Setup.exe /s /f1"%CD%\setup.iss"
SET setupexitcode=%ERRORLEVEL%
POPD

rem     Record an installation with this command:SamsungGSBN_Installer.exe /r /f1"X:\setup.iss"
rem     Now you can perform a silent installation with the iss file:SamsungGSBN_Installer.exe /s /f1"X:\setup.iss"
RD /S /Q "%TEMP%\SamsungGSBN_Installer"
EXIT /B %setupexitcode%
