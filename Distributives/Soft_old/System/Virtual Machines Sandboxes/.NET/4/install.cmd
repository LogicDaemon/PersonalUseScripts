@REM coding:OEM
SETLOCAL

IF "%RunUnteractiveInstalls%"=="1" (
    SET switches=%switches% /passive /showfinalerror
) ELSE (
    SET switches=%switches% /q
)
IF NOT DEFINED MSILog4 (
    SET MSILog4=%TEMP%\dotNetFx40_Client_x86_x64-install.log
    IF DEFINED MSILog SET MSILog4=%MSILog%
)
IF NOT DEFINED MSILog45 (
    SET MSILog45=%TEMP%\dotNetFx45_Full_setup.log
    IF DEFINED MSILog SET MSILog45=%MSILog%
)

rem "%~dp0dotNetFx40_Client_x86_x64.exe" /norestart %switches% /log "%MSILog4%"
rem "%~dp0dotNetFx45_Full_setup.exe" /norestart %switches% /log "%MSILog45%"
"%~dp0netfx_fullcab.exe" /norestart %switches% /log "%MSILog45%"

"%~dp0NDP451-KB2858728-x86-x64-AllOS-ENU.exe" /norestart %switches% /log "%MSILog45%"
"%~dp0NDP451-KB2858728-x86-x64-AllOS-RUS.exe" /norestart %switches% /log "%MSILog45%"

EXIT /B

Usage:		Setup [switches] 
		All switches are optional. 

/CEIPconsent - Optionally send anonymous feedback to improve the customer experience. 
/chainingpackage <name> - Optionally record the name of a package chaining this one. 
/createlayout <full path> - Download all files and associated resources to the specified location. Perform no other action.  * Disabled * 
/lcid - Set the display language to be used by this program, if possible. Example: /lcid 1031 
/log <file | folder> - Location of the log file. Default is the process temporary folder with a name based on the package. 
/msioptions - Specify options to be passed for .msi and .msp items. Example: /msioptions "PROPERTY1='Value'" 
/norestart - If the operation requires a reboot to complete, Setup should neither prompt nor cause a reboot. 
/passive - Shows progress bar advancing but requires no user interaction. 
/showfinalerror - Passive mode only: shows final page if the install is not successful. 
/pipe <name> - Optionally create a communication channel to allow a chaining package to get progress. 
/promptrestart - If the operation requires a reboot to complete, Setup should prompt, and trigger it if the user agrees. 
/q - Quiet mode, no user input required or output shown. 
/repair - Repair the payloads. 
/serialdownload - Force install operation to happen only after all the payload is downloaded. 
/uninstall - Uninstall the payloads. 
/parameterfolder <full path> - Specifies the path to the Setup's configuration and data files. 
/NoSetupVersionCheck - Do not check ParameterInfo.xml for setup version conflicts. 
/uninstallpatch {patch code} - Removes update for all products the patch has been applied to. 
/? - Display this help.

Examples:

Silently install the package and create log file SP123.htm in the temp folder:	Setup /q /log %temp%\SP123.htm
Install with no user interaction unless reboot is needed to complete the operation:	Setup /passive /promptrestart

Some command line switches are disabled for this package: createlayout
(c) Microsoft Corporation. All Rights Reserved.
