@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem aws sso login --profile AdministratorAccess-572304703581
rem use --boto-profile AdministratorAccess-572304703581 in the following line for SSO
SET "region=%~1"
IF NOT DEFIEND region SET "region=eu-central-1"
SET "asgname=%~2"
)
@IF NOT DEFINED asgname SET "asgname=am-prod-media-asg-%region%"
(
CALL "%~dp0py.cmd" "%~dp0py\connect-asg-host\prepare-asg-host-connection.py" --region %region% --asg %asgname% --boto-profile 684914159219_AdministratorAccess --ssh-connection prodasg --putty-connection prodasg
putty -load prodasg
)
