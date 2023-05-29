@(REM coding:CP866
SETLOCAL ENABLEEXTENSIONS

SET "PATH=%LocalAppData%\Programs\ADB\platform-tools;%PATH%"
"%LocalAppData%\Programs\ADB\platform-tools\%~n0.exe" %*
)
