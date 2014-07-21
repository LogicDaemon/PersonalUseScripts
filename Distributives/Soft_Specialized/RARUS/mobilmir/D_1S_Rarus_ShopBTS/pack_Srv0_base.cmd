@REM coding:OEM
@ECHO OFF

CALL "\\Srv0\profiles$\Share\config\_Scripts\find7zexe.cmd"

CALL 7z_get_switches.cmd
SET today=%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%
SET ArcPrefix=%~dp0

SET DLLsArcName=%ArcPrefix%ShopBTS_Add_DLLs.7z
rem SET MainBaseArcName=%ArcPrefix%ShopBTS_InitialBase_251+MD%today%.7z
SET MainBaseArcName=%ArcPrefix%ShopBTS_InitialBase_251+MD-auto-daily.7z

START "" /B /WAIT /D"W:\1С Базы\Бза Для установки на отделы\ShopBTS" %exe7z% a -r %z7zswitchesLZMA2% -ir@"%~dpn0.dlllist.txt" "%DLLsArcName%" || (PAUSE & EXIT /B 32767)

IF EXIST "%MainBaseArcName%" MOVE /Y "%MainBaseArcName%" "%MainBaseArcName%.bak"
%exe7z% a -r %z7zswitchesLZMA2% -xr0@"%~dpn0.excludelist.txt" -xr0@"%~dpn0.dlllist.txt" "%MainBaseArcName%" "W:\1С Базы\Бза Для установки на отделы\ShopBTS\*" || (PAUSE & EXIT /B 32767)
rem FOR %%I IN ("%ArcPrefix%ShopBTS_InitialBase_251+MD*.7z") DO IF NOT "%%~I"=="%MainBaseArcName%" DEL "%%~I"
