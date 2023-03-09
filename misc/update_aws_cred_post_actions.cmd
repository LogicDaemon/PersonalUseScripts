@(REM coding:CP866
    START "" /D "%USERPROFILE%\.aws" /B pscp -load am-qa-fs-05 -batch credentials am-qa-fs-05.anymeeting-qa.com:/home/aderbenev/.aws

    FOR /F "usebackq tokens=1,2*" %%A IN (`REG QUERY "HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions\DEV-FS-05" /v "HostName"`) DO (
        IF "%%~A"=="HostName" START "" /D "%USERPROFILE%\.aws" /B /WAIT pscp -load DEV-FS-05 -batch credentials "%%~C:/home/aderbenev/.aws"
    )
)
