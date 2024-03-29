@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
ECHO OFF
%SystemRoot%\System32\fltmc.exe >nul 2>&1 || ( ECHO ��ਯ� "%~f0" ��� �ࠢ ����������� �� ࠡ�⠥� & PING -n 30 127.0.0.1 >NUL & EXIT /B )
SETLOCAL ENABLEEXTENSIONS
IF DEFINED PROCESSOR_ARCHITEW6432 "%SystemRoot%\SysNative\cmd.exe" /C "%0 %*" & EXIT /B
    
    CALL "%~dp0..\Check Power Profile Name.cmd" WSUSTemp || (
	ECHO ����騩 ��䨫� ��⠭�� ��⠫�� �� WSUSOffline. ������ ���. ���஡����: https://trello.com/c/V2yWUnul
	IF DEFINED Unattended EXIT /B
	PAUSE
    )
    CALL "%~dp0..\FindAutoHotkeyExe.cmd" || (ECHO Autohotkey.exe �� ������! & IF DEFINED Unattended PAUSE)
    
    IF NOT DEFINED Unattended IF "%RunInteractiveInstalls%"=="0" SET "Unattended=1"
    IF NOT DEFINED backupscriptpath IF NOT DEFINED Unattended CALL :AskForBackupScriptPath
)
(
    ECHO %DATE% %TIME% backupscriptpath: %backupscriptpath%

    %AutohotkeyExe% "%~dp0..\GUI\Find Trash on SystemDrive.ahk"
    ECHO %DATE% %TIME% �������� �� � ���������� � ��।� ��⠭����...
    CALL "%~dp0uninstall_soft.cmd"

    START "BleachBit" /WAIT %comspec% /C "%~dp0BleachBit-auto.cmd" /ProfileOnSystemDrive
    IF EXIST "%SystemDrive%\bootsqm.dat" (
	ECHO %DATE% %TIME% �������� bootsqm.dat
	DEL "%SystemDrive%\bootsqm.dat"
    )

    ECHO %DATE% %TIME% �������� ᮤ�ন���� %windir%\TEMP
    FOR /D %%I IN ("%windir%\TEMP\*.*") DO RD /S /Q "%%~fI"
    DEL /F /S /Q "%windir%\TEMP\*.*"

    ECHO %DATE% %TIME% �������� ᮤ�ন���� %windir%\Logs\CBS
    FOR /D %%I IN ("%windir%\Logs\CBS\*.*") DO RD /S /Q "%%~fI"
    DEL /F /S /Q "%windir%\Logs\CBS\*.*"

    ECHO %DATE% %TIME% �������� ᮤ�ন���� %TEMP%
    FOR /D %%I IN ("%TEMP%\*") DO RD /S /Q "%%~fI"
    DEL /F /S /Q "%TEMP%\*.*"

    ECHO %DATE% %TIME% ���⪠ ��䨫� Install
    IF EXIST %SystemDrive%\Users\Install (
	DEL /Q "%SystemDrive%\Users\Install\AppData\Local\GDIPFONTCACHEV1.DAT"
	DEL /Q "%SystemDrive%\Users\Install\AppData\Local\IconCache.db"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Google"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Microsoft\Windows Store"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Microsoft\Windows\ConnectedSearch"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Microsoft\Windows\SettingSync"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Microsoft\Windows\WebCache"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Local\Microsoft\Windows\WER"
	RD /S /Q "%SystemDrive%\Users\Install\AppData\Roaming\LibreOffice"
    )

    ECHO %DATE% %TIME% ���⪠ ��襩 � ��䨫�� ���짮��⥫�� "%SystemDrive%\Users\*"
    CALL "%~dp0Apps\Cleanup AppData - remove Caches.cmd" "%SystemDrive%\Users\*"

    ECHO %DATE% %TIME% �������� ��ୠ��� USN
    fsutil usn deletejournal /D %SystemDrive%
    rem -- �� ���������� � ����� -- fsutil usn deletejournal /D %SystemDrive%\WINDOWS\SwapSpace

    ECHO %DATE% %TIME% Emptying SoftwareDistribution\Download
    START "SoftwareDistribution\Download" /WAIT %comspec% /C "%~dp0Empty SoftwareDistribution_Download.cmd" /NOWAIT || PAUSE
    ECHO %DATE% %TIME% Removing Windows Search Index
    START "Windows Search Index" /WAIT %comspec% /C "%~dp0Remove Windows Search Index.cmd" /NOWAIT

    ECHO %DATE% %TIME% ���⪠ �����祭�

    IF DEFINED backupscriptpath (
	ECHO ��१ 5 ᥪ㭤 ��������� %backupscriptpath%. �᫨ �� ������⥫쭮, ������ ०�� �뤥����� � �⮬ ����.
	PING 127.0.0.1 -n 6 -w 1000 >NUL
	ECHO %DATE% %TIME% ��砫� १�ࢭ��� ����஢����...
	START "%backupscriptpath%" /I /WAIT %comspec% /C "%backupscriptpath%" && (
	    ECHO %DATE% %TIME% �����襭� �ᯥ譮. �������� 15 �.
	    PING 127.0.0.1 -n 15 >NUL
	)
	CALL :CheckEchoError || PAUSE
    ) ELSE (
	ECHO.
	ECHO.
	ECHO %DATE% %TIME% ���⪠ �����祭�. ������ ����� ������ १�ࢭ�� �����.
	ECHO ��᫥ १�ࢭ��� ����஢���� ������ � �⮬ ���� ���� �������, �� �� ��।� �㤥� ��⠭������.
	PAUSE
    )
)
(
    ECHO %DATE% %TIME% ��⠭���� �� �� ��।�...
    %comspec% /C "%~dp0..\_software_install_queued.cmd"
    
    EXIT /B
)

:AskForBackupScriptPath
(
    ECHO.
    ECHO ��᫥ 㤠����� �ணࠬ� � ���⪨ �㤥� ����饭 �ਯ�.
    ECHO ���筮 �� �ਯ� ��� ᮧ����� १�ࢭ�� �����.
    ECHO ��� ����� ��� �ਯ�?
    ECHO ������ ����� ���� � �ਯ��, ����
    ECHO ���� ^(Enter^)	���� �ᯮ������� ^(�㪢� ��᪮�, \\IT-Head, \\AcerAspire7720G^)
    ECHO 1		���� "backup image to R and copy here.cmd"
    ECHO 2		���� "backup image here and copy to R.cmd"
    ECHO 0		�� ����᪠�� �ਯ�, ����� �⮣� ����� ������ �� ������
    SET /P dobackup=^> 
)
(
    IF "%dobackup%"=="0" EXIT /B 0
    IF "%dobackup%"=="" (
        CALL :FindBackupScriptPath "Run WindowsImageBackup.cmd" && EXIT /B
        CALL :FindBackupScriptPath "backup image to R and copy here.cmd" && EXIT /B
        CALL :FindBackupScriptPath "backup image here and copy to R.cmd"
        EXIT /B
    )
    IF "%dobackup%"=="1" CALL :FindBackupScriptPath "backup image to R and copy here.cmd" & EXIT /B
    IF "%dobackup%"=="2" CALL :FindBackupScriptPath "backup image here and copy to R.cmd" & EXIT /B
    SET "backupscriptpath=%dobackup%"
EXIT /B 1
)
:FindBackupScriptPath
    ECHO %DATE% %TIME% searching for %1 on local drives and in predefined network locations
    FOR %%I IN (D: E: F: G: H: I: J: K: L: M: N: O: P: Q: S: T: U: V: W: X: Y: Z: A: B: "\\IT-Head.office0.mobilmir\Backup" "\\AcerAspire7720G.office0.mobilmir\wbadmin-Backups") DO (
	REM "IF EXIST" shows message box "drive not ready" with 3 buttons when hitting a drive w/o media. So use DIR!
	rem DIR "%%~I\%~nx1" || ECHO.| NET USE "%%~I" /user:guest ""
	DIR "%%~I\%~nx1" || ECHO.| NET USE "%%~I" /user:guest0 0
	DIR "%%~I\%~nx1" && (
	    SET "backupscriptpath=%%~I\%~nx1"
	    EXIT /B
	)
    )
EXIT /B 1

:CheckEchoError
(
    IF ERRORLEVEL 1 (
	ECHO %DATE% %TIME% ��� �訡��: %ERRORLEVEL%
    )
EXIT /B
)
