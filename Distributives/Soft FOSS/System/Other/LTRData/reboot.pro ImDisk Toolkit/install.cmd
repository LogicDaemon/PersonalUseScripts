@(REM coding:CP866
    IF NOT DEFINED exe7z CALL find7zexe.cmd
    IF NOT DEFINED exe7z SET "exe7z=%~dp0..\..\..\..\..\Soft\PreInstalled\utils\7za64.exe"
)
@(
    %exe7z% x -aoa -y -o"%TEMP%\ImDiskTk" "%~dp0ImDiskTk-x64.zip" || EXIT /B
    FOR /D %%D IN ("%TEMP%\ImDiskTk\*.*") DO @(
        IF EXIST "%%~D\files.cab" (
            extrac32.exe /e /l "%TEMP%\ImDiskTk\files" "%%~D\files.cab"
            "%TEMP%\ImDiskTk\files\config.exe" /fullsilent /discutils:1 /ramdiskui:1 /menu_entries:0 /shortcuts_desktop:0 /shortcuts_all:1
            RD /S /Q "%TEMP%\ImDiskTk\files"
        )
    )
    RD /S /Q "%TEMP%\ImDiskTk"
    EXIT /B
)
rem ---------------------------
rem ImDisk - Setup
rem ---------------------------
rem Switches:

rem /silent
rem Silent installation. Error messages and reboot prompt are still displayed.

rem /fullsilent
rem Silent installation, without error message or prompt. No reboot will occur, even if files are in use.

rem /installfolder:"path"
rem Set the installation folder.

rem /lang:name
rem Bypass automatic language detection. 'name' is one of the available languages.

rem /OPTION:[0|1]
rem Force an installation option to be selected or not.
rem OPTION can be one of the followings: discutils, ramdiskui, menu_entries, shortcuts_desktop, shortcuts_all.

rem /silentuninstall
rem Silent uninstallation. Driver (and therefore all existing virtual disk) and parameters are removed. This switch can also be passed to config.exe.

rem /version
rem Return the application version in the standard output and the exit code.
rem ---------------------------
rem OK   
rem ---------------------------
