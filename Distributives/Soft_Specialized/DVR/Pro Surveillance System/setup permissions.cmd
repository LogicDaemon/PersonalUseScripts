@REM coding:OEM
(
SETLOCAL ENABLEEXTENSIONS
REM Set up permission to use PSS by non-admin user
REM                                              by logicdaemon@gmail.com
REM                                                        logicdaemon.ru
REM
REM This work by LogicDaemon is licensed under a Creative Commons Attribution 3.0 Unported License.
REM http://creativecommons.org/licenses/by/3.0/

SET lProgramFiles=%ProgramFiles%
IF DEFINED ProgramFiles(x86) SET lProgramFiles=%ProgramFiles(x86)%

IF NOT DEFINED SetACLexe CALL "\\192.168.1.80\profiles$\Share\config\_Scripts\find_exe.cmd" SetACLexe SetACL.exe
)
IF NOT DEFINED SetACLexe (
    ECHO SetACL.exe не найден, продолжение невозможно.
    EXIT /B 2
)
(
SET UIDEveryone=S-1-1-0;s:y
SET UIDAuthenticatedUsers=S-1-5-11;s:y
SET UIDUsers=S-1-5-32-545;s:y
SET UIDSYSTEM=S-1-5-18
SET UIDCreatorOwner=S-1-3-0

SET FilePermMaskList=%~f0
SET RegistryPermKeyList=%~f0
)

FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "-!!! files list -" "%FilePermMaskList%"`) DO SET FilePermMaskSkip=skip=%%I
FOR /F "usebackq tokens=1 delims=[]" %%I IN (`find /n "-!!! reg list -" "%RegistryPermKeyList%"`) DO SET RegistryPermSkip=skip=%%I

FOR /F "usebackq %RegistryPermSkip% delims=" %%I IN ("%RegistryPermKeyList%") DO %SetACLexe% -on "%%I" -ot reg -rec yes -actn ace -ace "n:%UIDUsers%;p:full;i:so,sc;m:set;w:dacl"

%SetACLexe% -on "%lProgramFiles%\Pro Surveillance System" -ot file -actn ace -ace "n:%UIDUsers%;p:FILE_ADD_FILE,FILE_ADD_SUBDIRECTORY;i:sc;m:set;w:dacl"
FOR /F "usebackq %FilePermMaskSkip% delims=" %%I IN ("%FilePermMaskList%") DO (
    IF "%%~I"=="" GOTO :EndFilesList
    IF "%%~I"=="-!!! reg list -" GOTO :EndFilesList
    FOR %%J IN ("%lProgramFiles%\%%~I") DO %SetACLexe% -on "%%~fJ" -ot file -actn ace -ace "n:%UIDUsers%;p:change;i:so,sc;m:set;w:dacl"
)
:EndFilesList

ENDLOCAL
EXIT /B

-!!! files list -
Pro Surveillance System\*.xml
Pro Surveillance System\*.db
Pro Surveillance System\*.ini

-!!! reg list -
HKCR\CLSID\{302F0E5A-E348-46F2-83A5-C0B3ABB68BE5}
HKCR\CLSID\{324FA73F-4BF9-4F39-AB80-2947DB8D8461}
HKCR\CLSID\{372B5E07-0D7F-496E-8023-8F34EEFB0521}
HKCR\CLSID\{38F1C772-6F02-4A73-9695-5DA49ED7E9FF}
HKCR\CLSID\{3BCFDA2D-B65C-4CFE-82AC-923CCA89739A}
HKCR\CLSID\{3CBEA88F-AAA4-46BD-96A2-62112977034A}
HKCR\CLSID\{478D19D4-72A3-4D2C-B5D9-9EA71DB0A86B}
HKCR\CLSID\{496BEC23-C566-472D-8ABD-DC85CC4C8DE3}
HKCR\CLSID\{75509A2F-80B6-4E96-951E-E89F640958A0}
HKCR\CLSID\{7603AB5C-BE21-40FB-99B2-4909B053ECB6}
HKCR\CLSID\{9C04F93E-75AF-4705-8C7E-E266283544AF}
HKCR\CLSID\{A53DC105-7E10-4868-90D4-311E538B8ED0}
HKCR\CLSID\{C32F81B2-571C-4AC0-82FB-6D9E18259617}
HKCR\CLSID\{CA70E147-E32A-4A69-A927-1D43DFE9D3CF}
HKCR\CLSID\{CD2D4B6A-F5BE-45AD-93BE-AC72FB797B00}
HKCR\CLSID\{F73EE01A-D24C-45DA-AE94-8D348DE98BBA}
HKCR\CLSID\{FCAC9E98-95CF-4048-824E-61207041BC58}
HKCR\CLSID\{FE1DB4C0-1E61-4A78-AE59-B41D1028B948}
HKCR\CONFIGPACK.ConfigPackCtrl.1
HKCR\DAYTIMEPICK.DayTimePickCtrl.1
HKCR\DHDEVICECONFIG.DHDeviceConfigCtrl.IPHD
HKCR\DHDEVICECONFIG.DHDeviceConfigCtrl.PSS
HKCR\DVRINTERVIDEO.DvrInterVideoCtrl.IPHD
HKCR\DVRINTERVIDEO.DvrInterVideoCtrl.PSS
HKCR\MAPACTIVEX.MapActiveXCtrl.1
HKCR\MAPCTRL.MapCtrlCtrl.PSS
HKCR\VIDEOWINDOW.VideoWindowCtrl.PSS
