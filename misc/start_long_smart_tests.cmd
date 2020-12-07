@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    SET smartctlexe="%LocalAppData%\Programs\smartmontools\smartctl.exe"
)
(
    FOR /F "usebackq eol=# tokens=1" %%A IN (`%smartctlexe% --scan-open`) DO (
        (
            %smartctlexe% -i %%A
            %smartctlexe% -t long %%A
        ) | tee -a "%TEMP%\smartctl-%%~nxA.log"
    )
    EXIT /B
)
