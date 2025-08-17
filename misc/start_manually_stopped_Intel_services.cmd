@(REM coding:CP866
REM 0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS
)

rem Intel(R) Dynamic Application Loader Host Interface Service
sc start jhi_service
rem Intel(R) Dynamic Tuning Technology Telemetry Service
sc start dptftcs
rem Intel(R) Graphics Command Center Service
sc start igccservice
rem Intel(R) Innovation Platform Framework Service
sc start ipfsvc
