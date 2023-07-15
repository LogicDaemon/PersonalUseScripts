@REM coding:OEM
%SystemRoot%\System32\ippon_ups.exe /uninstall
7z e -y -aoa -o"%SystemRoot%\System32" -- "%~dp0ipponups3b5.zip" x86\ippon_ups.exe x86\ippon_dll.dll
%SystemRoot%\System32\ippon_ups.exe /install
