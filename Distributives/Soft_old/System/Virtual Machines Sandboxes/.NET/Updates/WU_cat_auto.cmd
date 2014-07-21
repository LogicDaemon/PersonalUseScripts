@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF "%RunInteractiveInstalls%"=="0" (
    SET LogOffAfterInstall=0
    SET RebootAfterInstall=0
)

IF NOT DEFINED ActionAfterInstall IF NOT DEFINED LogOffAfterInstall IF NOT DEFINED LogOffAfterInstall (
    SET /P ActionAfterInstall=После установки: 1 - перезагрузка, 2 - завершить сеанс, остальное - ничего: 
)
IF "%ActionAfterInstall%"=="1" SET RebootAfterInstall=1
IF "%ActionAfterInstall%"=="2" SET LogOffAfterInstall=1

FOR /D %%i IN (%srcpath%cat\*.*) DO (
    ECHO %%i
    CALL %srcpath%WU_cat_installsingle.cmd "%%i"
)

IF "%LogOffAfterInstall%"=="1" LOGOFF /V
IF "%RebootAfterInstall%"=="1" shutdown -r -t 0
