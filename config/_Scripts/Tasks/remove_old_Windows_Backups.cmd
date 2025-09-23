@REM coding:OEM

IF NOT DEFINED exe7z CALL "%~dp0..\find7zexe.cmd" || EXIT /B
IF NOT EXIST "%ProgramData%\Common_Scripts\Remove Old Windows Backups.ahk" CALL "\\Server.local\Distributives\Soft\PreInstalled\auto\Common_Scripts.cmd"

rem schtasks /Delete /TN "Remove Old Windows 7 Backups" /F
%exe7z% x -o"%TEMP%" -- "%~dp0Tasks.XML.7z" "Remove Old Windows Backups.xml"
schtasks /Delete /TN "Remove Old Windows 7 Backups" /F
schtasks /Create /TN "Remove Old Windows Backups" /XML "%TEMP%\Remove Old Windows Backups.xml" /RU "" /F
DEL "%TEMP%\Remove Old Windows Backups.xml"
