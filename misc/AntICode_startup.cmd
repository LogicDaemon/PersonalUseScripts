@(REM coding:CP866
rem CALL "%~dp0CreateTempDirs on RAM-drive.cmd"

REM start "SynTP" /MIN /D"C:\Program Files\Synaptics\SynTP" "C:\Program Files\Synaptics\SynTP\SynTPEnh.exe"
REM start "SynTP" /MIN /D"C:\Program Files\Synaptics\SynTP" "C:\Program Files\Synaptics\SynTP\SynTPLpr.exe"
rem start "BluetoothAuthenticationAgent" /MIN %windir%\system32\rundll32.exe bthprops.cpl,,BluetoothAuthenticationAgent
rem start "BToes" /MIN "C:\Program Files\MSI\BToes Программное обеспечение Bluetooth\BTTray.exe"

rem START "" /D"C:\Program Files\OSCAR Editor" "OscarEditor.exe" Minimum

rem HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
rem Dropbox Update	Dropbox Update	Dropbox, Inc.	"D:\Users\LogicDaemon\AppData\Local\Dropbox\Update\DropboxUpdate.exe" /c
rem START "" /LOW "D:\Users\LogicDaemon\AppData\Local\Dropbox\Update\DropboxUpdate.exe" /c

START "Autohotkey" /HIGH "c:\Program Files\AutoHotkey\AutoHotkey.exe" "%~dp0Hotkeys.ahk"

CALL "%~dp0Update_SysInternals.cmd"
START "Autohotkey" /HIGH "c:\Program Files\AutoHotkey\AutoHotkey.exe" "%~dp0UpdateStartMenuShortcuts.ahk"
)
