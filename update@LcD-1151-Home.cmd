@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
CALL "%~dp0update_Distributives_scripts.cmd" "d:\Distributives" "%~dp0Distributives"
@REM ahk "%~dp0unpack_Distributives_config.ahk"

robocopy "%USERPROFILE%\Dropbox\Projects\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\Setup\Win10" "%~dp0Setup\Win10" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\Setup" "%~dp0Setup" "Logitech Gaming Software en-US.reg"
@REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
robocopy "%LOCALAPPDATA%\Scripts" "%~dp0misc" /MIR /XD .mypy_cache Photo temp-backup-scripts /XF Hotkeys_Custom.ahk Hotkeys_Custom.*.ahk KeePass_*.ahk *.lnk
robocopy "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo" /MIR /XD old /XF *.lnk "Copy photos from flash cards.destinations.txt"
)
