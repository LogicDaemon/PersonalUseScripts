@(REM coding:CP866
REM ;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
SETLOCAL ENABLEEXTENSIONS

SET "PATH=%LocalAppData%\Programs\msys64\bin;%LocalAppData%\Programs\msys64\usr\bin;%PATH%"
rem "%LocalAppData%\Programs\msys64\usr\bin\rsync.exe"
rem "%LocalAppData%\Programs\msys64\ucrt64.exe" 
"%LocalAppData%\Programs\msys64\usr\bin\rsync.exe" %*
)
