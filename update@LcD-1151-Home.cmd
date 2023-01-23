@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS
robocopy "d:\Distributives\config" "%~dp0Distributives\config" /MIR /S /XD d:\Distributives\config\_Scripts\Lib
robocopy "d:\Distributives" "%~dp0Distributives" *.cmd *.ahk *.list descript.ion "partial list of free SysUtils.txt" jre_install_common.cfg opabackup342.exe.config /MIR /S /XD config Drivers_local Local_Scripts wsusoffline
ahk "%~dp0unpack_Distributives_config.ahk"

robocopy "%USERPROFILE%\Dropbox\Projects\AutoHotkey\Lib" "%~dp0AutoHotkey\Lib" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\Setup\Win10" "%~dp0Setup\Win10" /MIR
robocopy "%USERPROFILE%\Dropbox\Projects\Setup" "%~dp0Setup" "Logitech Gaming Software en-US.reg"
@REM TODO: cipher /U /N /H ., and parse the output to skip encrypted files instead of hardcoding them here
robocopy "%LOCALAPPDATA%\Scripts" "%~dp0misc" /MIR /XD .mypy_cache Photo temp-backup-scripts software_update /XF Hotkeys_Custom.ahk Hotkeys_Custom.*.ahk KeePass_*.ahk *.lnk
robocopy "%LOCALAPPDATA%\Scripts\Photo" "%~dp0Photo" /MIR /XD old /XF *.lnk "Copy photos from flash cards.destinations.txt"
CALL "%~dp0update.finalize.cmd"
)
