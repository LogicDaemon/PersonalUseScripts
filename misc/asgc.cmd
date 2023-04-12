@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
rem aws sso login --profile AdministratorAccess-572304703581
rem use --boto-profile AdministratorAccess-572304703581 in the following line for SSO
CALL "%~dp0py.cmd" "%~dp0py\connect-asg-host\prepare-asg-host-connection.py" --asg ASG-MEDIA --boto-profile 572304703581_AdministratorAccess
)
