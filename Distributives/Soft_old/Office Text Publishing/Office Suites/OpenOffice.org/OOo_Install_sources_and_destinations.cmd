@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

SET scriptdir=%SystemDrive%\Local_Scripts
SET OOoSourceArchiveMask=OOo_*_Win_x86_install*.exe
SET OOoTempDir=%Temp%\OOo_Distributive
SET MSIMask=openofficeorg*.msi
FOR /F "usebackq delims=" %%I IN (`%SystemDrive%\SysUtils\UnxUtils\find "%srcpath:~0,-1%" -name "%OOoSourceArchiveMask%"`) DO SET OOoSourceArchive=%%~I
IF NOT DEFINED OOoSourceArchive FOR %%I IN ("%srcpath%%OOoSourceArchiveMask%") DO SET OOoSourceArchive=%%~fI
IF NOT DEFINED OOoSourceArchive EXIT /B 1
