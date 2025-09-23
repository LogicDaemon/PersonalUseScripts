@(REM coding:CP866
IF NOT DEFINED logfile SET logfile="%SystemRoot%\Logs\%~n0.log"
IF NOT DEFINED configDir CALL :GetConfigDir
)
IF NOT DEFINED DistSourceDir CALL "%ConfigDir%_Scripts\FindSoftwareSource.cmd"
(
CALL "%SoftSourceDir%\Office Text Publishing\PDF\Adobe Reader\install.cmd"
) >>%logfile% 2>&1
EXIT /B

:GetConfigDir
IF NOT DEFINED DefaultsSource CALL "%ProgramData%\Common_Scripts\_get_defaultconfig_source.cmd" ^
    || CALL "%SystemDrive%\Local_Scripts\_get_defaultconfig_source.cmd"
(
CALL :GetDir ConfigDir "%DefaultsSource%"
EXIT /B
)
:GetDir
(
    SET "%~1=%~dp2"
EXIT /B
)
