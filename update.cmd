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
robocopy "d:\Distributives" "%~dp0Distributives" *.cmd *.ahk *.list descript.ion "partial list of free SysUtils.txt" jre_install_common.cfg opabackup342.exe.config /MIR /S /XD config Drivers_local Local_Scripts wsusoffline
ATTRIB -R -S -H /S "%~dp0"
ahk "%~dp0unpack_Distributives_config.ahk"
)
