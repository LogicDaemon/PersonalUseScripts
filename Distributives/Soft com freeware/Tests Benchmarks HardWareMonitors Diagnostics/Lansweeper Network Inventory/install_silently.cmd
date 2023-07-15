@REM coding:OEM
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

"%srcpath%LansweeperSetup.exe" /SP- /VERYSILENT /SUPPRESSMSGBOXES /LOG /NORESTART /CLOSEAPPLICATIONS /NORESTARTAPPLICATIONS 

EXIT /B

---------------------------
Setup
---------------------------
The Setup program accepts optional command line parameters.
/HELP, /?
Shows this information.
/SP-
Disables the This will install... Do you wish to continue? prompt at the beginning of Setup.
/SILENT, /VERYSILENT
Instructs Setup to be silent or very silent.
/SUPPRESSMSGBOXES
Instructs Setup to suppress message boxes.
/LOG
Causes Setup to create a log file in the user's TEMP directory.
/LOG="filename"
Same as /LOG, except it allows you to specify a fixed path/filename to use for the log file.
/NOCANCEL
Prevents the user from cancelling during the installation process.
/NORESTART
Prevents Setup from restarting the system following a successful installation, or after a Preparing to Install failure that requests a restart.
/RESTARTEXITCODE=exit code
Specifies a custom exit code that Setup is to return when the system needs to be restarted.
/CLOSEAPPLICATIONS
Instructs Setup to close applications using files that need to be updated.
/NOCLOSEAPPLICATIONS
Prevents Setup from closing applications using files that need to be updated.
/RESTARTAPPLICATIONS
Instructs Setup to restart applications.
/NORESTARTAPPLICATIONS
Prevents Setup from restarting applications.
/LOADINF="filename"
Instructs Setup to load the settings from the specified file after having checked the command line.
/SAVEINF="filename"
Instructs Setup to save installation settings to the specified file.
/LANG=language
Specifies the internal name of the language to use.
/DIR="x:\dirname"
Overrides the default directory name.
/GROUP="folder name"
Overrides the default folder name.
/NOICONS
Instructs Setup to initially check the Don't create a Start Menu folder check box.
/TYPE=type name
Overrides the default setup type.
/COMPONENTS="comma separated list of component names"
Overrides the default component settings.
/TASKS="comma separated list of task names"
Specifies a list of tasks that should be initially selected.
/MERGETASKS="comma separated list of task names"
Like the /TASKS parameter, except the specified tasks will be merged with the set of tasks that would have otherwise been selected by default.
/PASSWORD=password
Specifies the password to use.
For more detailed information, please visit http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline
---------------------------
OK
---------------------------
