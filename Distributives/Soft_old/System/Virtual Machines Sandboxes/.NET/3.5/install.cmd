@REM coding:OEM
SETLOCAL

IF "%RunUnteractiveInstalls%"=="1" (
    SET switches=%switches% /passive
) ELSE (
    SET switches=%switches% /q
)

IF NOT DEFINED MSILog SET MSILog=%TEMP%\dotnetfx35sp1-install.log
SET switches=%switches% /log "%MSILog%"

"%~dp0dotnetfx35sp1.exe" /norestart  %switches%

EXIT /B

Microsoft .NET Framework 3.5 SP1 - Usage
/q - Suppresses all UI. An .INI file cannot be specified with this option.
/quiet - Same as /q.
/qb - Displays minimal UI, showing only progress.
/passive - Same as /qb.
/uninstall - Uninstalls product.
/remove - Same as /uninstall.
/f - Repairs all .NET Framework 3.0 components that are installed.
/nopatch - Specifies that patches are not applied and bypasses patch checking.
/norollback - Specifies that setup is not rolled back if a setup component fails.
/norestart - Specifies that the installer
