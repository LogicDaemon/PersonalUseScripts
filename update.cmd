@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
robocopy "%USERPROFILE%\Dropbox\Projects\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\AutoHotkey\Lib.docs" "%~dp0AutoHotkey\Lib.docs" /MIR
robocopy "%LocalAppData%\Scripts" "%~dp0misc" /MIR /XD Photo temp-backup-scripts /XF Hotkeys_Custom.ahk KeePass_LogicDaemon.ahk
robocopy "%LocalAppData%\Scripts\Photo" "%~dp0Photo" /MIR /XD old /XF *.lnk "Copy photos from flash cards.destinations.txt"
robocopy "%USERPROFILE%\Dropbox\Projects\Setup\Win10" "%~dp0Setup\Win10" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\Setup" "%~dp0Setup" "Logitech Gaming Software en-US.reg"
git add .
git commit -m "Autoupdate"
)
