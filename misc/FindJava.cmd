@(REM coding:CP866
FOR /D %%A IN ("%LocalAppData%\Programs\jdk-*") DO IF EXIST "%%~A\bin\javaw.exe" SET "javadir=%%~A"
)
