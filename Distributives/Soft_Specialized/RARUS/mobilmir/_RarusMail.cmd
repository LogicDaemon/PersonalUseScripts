@REM coding:OEM


SET findexe="\\Srv0\profiles$\Share\config\_Scripts\find_exe.cmd"
IF NOT DEFINED sedexe CALL %findexe% sedexe sed.exe "%SystemDrive%\SysUtils\UnxUtils\sed.exe" || (PAUSE & EXIT /B)
IF NOT DEFINED recodeexe CALL %findexe% recodeexe recode.exe %SystemDrive%\SysUtils\UnxUtils\recode.exe
IF NOT DEFINED mtprofiledir CALL :CheckExistenceSetVar mtprofiledir d:\Mail\Thunderbird\profile


PUSHD d:\1S\Rarus\ShopBTS\ExtForms\post||(PAUSE & EXIT /B)
    IF EXIST sendemail.cfg (
	ECHO %CD%\sendemail.cfg уже существует, он не будет перезаписан.
	GOTO :skipblat
    )
    CALL :GetRarusExchParams
    ECHO %rarusexchaddr%>sendemail.cfg
    ECHO %rarusexchpassword%>>sendemail.cfg
    :skipblat
POPD

PUSHD "%mtprofiledir%"||(PAUSE & EXIT /B)
    CALL :GetRarusExchParams
    %sedexe% -e "s/!rarusexchaddr!/%rarusexchaddr%/g" -e "s/!rarusexchlogin!/%rarusexchaddr%/g" prefs_RarusExch.js >>prefs.js
    %sedexe% -ir -f prefs_AddRarusExchAcc.sed prefs.js
POPD

EXIT /B

:GetRarusExchParams
    IF DEFINED rarusexchaddr GOTO :SkipAcquiringUserName

    CALL _get_SharedMailUserId.cmd
    IF DEFINED mailuserid (
	SET rarusexchuser=%mailuserid%
    ) ELSE SET /P rarusexchuser=Адрес "Обмен Рарус" (без @k.mobilmir.ru): 

    SET rarusexchaddr=%rarusexchuser%@k.mobilmir.ru
:SkipAcquiringUserName
    IF NOT DEFINED rarusexchpassword SET /P rarusexchpassword=Пароль: 
EXIT /B

:CheckExistenceSetVar
    IF EXIST "%~2" (
	SET %1=%2
    ) ELSE (
	SET /P %1=%2 not found. Enter correct path for %1: 
    )
EXIT /B
