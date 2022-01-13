@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS

    CALL :getbasename rolename "%CD%"
    SET "testPlay=%~1"
    IF NOT DEFINED testPlay SET "testPlay=test.yml"
    SET "testPlayDir=%~2"
    IF NOT DEFINED testPlayDir SET "testPlayDir=tests"
    SET "moreArgs=%3"
)
:appendnextarg
@(
    SET "moreArgs=%moreArgs% %3"
    IF NOT "%~4"=="" (
        SHIFT /3
        GOTO :appendnextarg
    )
)
(
    tar -cf - . | plink -load am-qa-fs-05 "rm -rf /tmp/role_test ; mkdir -p '/tmp/role_test/%rolename%' && cd '/tmp/role_test/%rolename%' && tar xf - && mv %testPlayDir%/* .. && ansible-playbook -i localhost, -e 'ansible_connection=local' ../%testPlay%"
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
