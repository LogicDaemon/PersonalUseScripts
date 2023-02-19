@(REM coding:CP866
  IF /I "%USERNAME%" NEQ "LogicDaemon" (
    ECHO Running as non-LogicDaemon [%USERNAME%]
    CALL "%~dp0..\Soft\PreInstalled\auto\SysUtils.cmd"
    CALL "%~dp0..\Soft\Keyboard Tools\AutoHotkey\install.cmd"
    CALL "%~dp0..\Soft\Archivers Packers\7Zip\install.cmd"
      
    CALL "%~dp0_Scripts\FindAutoHotkeyExe.cmd" "%~dp0_Scripts\MoveUserProfile\SetProfilesDirectory_D_Users.ahk"

    CALL "%~dp0_Scripts\registry\reg_home.cmd"
    
    net user LogicDaemon /Add && net localgroup Administrators LogicDaemon /Add && net localgroup Users LogicDaemon /Delete
    schtasks /Create /TN "LogicDaemon\_continue_setup" /TR "%~f0" /IT /RL HIGHEST /SC ONLOGON /RU LogicDaemon /f
    EXIT /B
  )
)
(
    ECHO running as LogicDaemon [%USERNAME%]
    IF "%USERPROFILE:~0,2%" NEQ "D:" (
        ECHO User profile is not on D:, it's in "%USERPROFILE%"
        PAUSE
    )
    START "" "%~dp0Users\Default\AppData\Local\mobilmir.ru\plain_grey_dark.deskthemepack"
    CALL "%~dp0_Scripts\registry\reg_LogicDaemon.cmd"
    CALL "%~dp0..\Soft\PreInstalled\manual\TotalCommander.cmd"
    CALL "%~dp0..\Soft com freeware\Network\HTTP\Vivaldi\install.cmd"
    :: https://aka.ms/vs/15/release/vc_redist.x64.exe
    
    CALL "%~dp0..\Soft com freeware\Libs Components\Microsoft Visual C++ Redistributable\install.cmd"
    CALL "%~dp0..\Soft com freeware\System\Other\Link Shell Extension (LSE)\HardLinkShellExt_silentinstall.cmd"
    REM gonna delete scheduled task
    schtasks /Delete /TN "LogicDaemon\_continue_setup" /f
)
