@(REM coding:CP866
    FOR /D %%A IN ("%LocalAppData%\Mozilla\Firefox\Profiles\*") DO (
        IF "%cleanup%"=="1" RD /S /Q "%%~A\cache2"
        COMPACT /C /S:"%%~A" /F /EXE:LZX
    )
)
