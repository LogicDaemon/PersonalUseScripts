@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS

	CALL FindAutoHotkeyExe.cmd
	IF NOT DEFINED AutohotkeyExe (
		ECHO Could not find AutoHotkey.exe
		EXIT /B 1
	)
	CALL _Distributives.find_subpath.cmd distributives "Soft\Keyboard Tools\AutoHotkey\*.exe"
)
(
	START "" /B /WAIT /D"%distributives%\Soft\Keyboard Tools\AutoHotkey" %comspec% /C ""%distributives%\Soft\Keyboard Tools\AutoHotkey\download.cmd""
	FOR /F "usebackq tokens=1*" %%A IN ("%distributives%\Soft\Keyboard Tools\AutoHotkey\ver.zip.txt") DO (
		SET "version=%%~A"
		SET "distfname=%%~B"
		REM errorlevel 1 if version of file is less than the new one
		REM errorlevel 0 if the current autohotkey is up to date
		CALL compareVersion.cmd %AutohotkeyExe% "%%~A" || GOTO :Update
	)
	EXIT /B
)
:Update
CALL :ReadRegHostname Hostname
CALL FindAutoHotkeyExe.cmd
CALL :GetDir AhkDir %AutohotkeyExe%
(
	CALL "%distributives%\Soft\Keyboard Tools\AutoHotkey\install_to_LOCALAPPDATA.cmd"
	PUSHD "%distributives%\Soft\PreInstalled\utils" || EXIT /B
	grep -vF " *AutoHotkeyU64.exe" utils.sha256 | grep -vF " *AutoHotkey.exe" >utils.sha256.tmp
	upx --ultra-brute -o"AutoHotkeyU64.exe" "%AhkDir%\AutoHotkeyU64.exe"
	upx --ultra-brute -o"AutoHotkey.exe" "%AhkDir%\AutoHotkeyU32.exe"
	sha256sum "AutoHotkeyU64.exe" | tee "AutoHotkeyU64.sha256" | tee -a utils.sha256.tmp
	sha256sum "AutoHotkey.exe" >>utils.sha256.tmp
	MOVE /Y utils.sha256.tmp utils.sha256
	POPD
	IF EXIST "%~dp0update_ahk@%Hostname%.cmd" CALL "%~dp0update_ahk@%Hostname%.cmd"
	EXIT /B
)
:ReadRegHostname <var>
(
	FOR /f "usebackq tokens=2*" %%I IN (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname"`) DO SET "%~1=%%~J"
EXIT /B
)
:GetDir <var> <path>
(
	SET "%~1=%~dp2"
EXIT /B
)
