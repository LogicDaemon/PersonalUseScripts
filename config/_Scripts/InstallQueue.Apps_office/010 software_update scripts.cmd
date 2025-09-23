@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
(
rem START "Software Update Scripts Installer" /I %comspec% /C ""%configDir%..\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
rem START "Software Update Scripts Installer" /I %comspec% /C ""\\Server.local\profiles$\Share\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
START "Software Update Scripts Installer" /I %comspec% /C ""\\Server.local\Users\Public\Shares\profiles$\Share\software_update\_install\install_software_update_scripts.cmd" /InstallAndMark"
EXIT /B
)

:GetConfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\Common_Scripts\_get_defaultconfig_source.cmd" ^
    || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
CALL :GetDir configDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
