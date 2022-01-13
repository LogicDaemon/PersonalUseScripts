@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
SETLOCAL ENABLEEXTENSIONS
    FOR /D %%A IN ("%PROGRAMFILES(X86)%\Microsoft\Edge\Application\*.*") DO IF EXIST "%%~A\Installer\setup.exe" (
        PUSHD "%%~A\Installer" || EXIT /B
        setup.exe --uninstall --msedge --system-level
    )

rem @rem coding:CP866

rem cd /d "%PROGRAMFILES(X86)%\Microsoft\Edge\Application\8*Installer" || PAUSE
rem setup.exe --uninstall --force-uninstall --system-level
rem setup.exe --uninstall --msedge --system-level
rem  --verbose-logging
)
