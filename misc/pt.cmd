@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

    CALL :getbasename rolename "%CD%"
    SET "testPlay=tests/cd...yml"
)
:appendnextarg
@(
    SET "moreArgs=%moreArgs% %1"
    IF NOT "%~2"=="" (
        SHIFT /1
        GOTO :appendnextarg
    )
    IF NOT EXIST "tests\cd...yml" (
        MKDIR ".\tests" 2>NUL
        XCOPY "%USERPROFILE%\Documents\Templates\tests\*.*" ".\tests" /E /Q /I 
    )
        
)
(
    tar -cf - . | plink -load am-qa-fs-05 "rm -rf /tmp/role_test ; mkdir -p '/tmp/role_test/%rolename%' && cd '/tmp/role_test/%rolename%' && tar xf - && ansible-playbook -i localhost, --connection=local %moreArgs% %testPlay%"
rem     -e 'ansible_connection=local'
EXIT /B
)
:getbasename <varname> <dirpath>
@(
SETLOCAL ENABLEEXTENSIONS
SET "v=%~2"
IF NOT DEFINED v EXIT /B
)
@IF "%v:~-1%"=="\" (SET "v=%v:~0,-1%" & GOTO :roundtrip)
@(
ENDLOCAL
SET "%1=%~nx2"
)
:roundtrip
@(
ENDLOCAL
CALL :getbasename %1 "%v%"
EXIT /B
)
