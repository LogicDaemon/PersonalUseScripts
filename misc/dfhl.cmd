@(REM coding:CP866
IF /I "%CD%"=="%WINDIR%" (
    ECHO This batch cannot work if started with a network drive as working directory. Use dfhl.exe instead.
    EXIT /B 1
)
"%LocalAppData%\Programs\DFHL_2.6\DFHL.exe" /w %* 2>&1 | tee -a DFHL.log
)
