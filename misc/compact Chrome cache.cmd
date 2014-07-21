@(REM coding:CP866
    FOR /D %%B IN ("%LocalAppData%\Google\Chrome*" "%LocalAppData%\Vivaldi*") DO @(
        IF EXIST "%%~B\." (
            COMPACT /C /S:"%%~B\Application" /F /EXE:LZX
            FOR /D %%P IN ("%%~B\User Data\*") DO @(
                IF EXIST "%%~P\Preferences" FOR /D %%C IN ("%%~P" "%%~P\Storage\ext\*") DO @(
                    ECHO Cleaning up %%C
                    REM + "File System"
                    FOR /D %%D IN ("Application Cache" "Cache" "Code Cache" "GPUCache" "Service Worker" "def\Application Cache" "def\Cache" "def\Code Cache" "def\GPUCache") DO @(
                        IF "%cleanup%"=="1" IF EXIST "%%~C\%%~D\." (
                            RD /S /Q "%%~C\%%~D"
                        ) ELSE (
                            COMPACT /C /S:"%%~C\%%~D" /F /EXE:LZX
                            COMPACT /C /S:"%%~C\%%~D"
                        )
                    )
                    COMPACT /Q /C /S:"%%~P\Extensions" /F /EXE:LZX
                )
            )
            COMPACT /Q /C /S:"%%~B"
        )
    )
    EXIT /B
)
