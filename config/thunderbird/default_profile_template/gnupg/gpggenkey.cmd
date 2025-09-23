@REM coding:OEM
@ECHO OFF
rem for XP only: diskperf.exe -y
@CHCP 65001 >NUL & (
    ECHO Key-Type: RSA
    ECHO Subkey-Type: RSA
    ECHO Expire-Date: 0
    ECHO Name-Real: %username%
    ECHO Name-Comment: Company full name
    ECHO Name-Email: %username%@company.com
) | gpg --gen-key --batch & CHCP 866

SET gpgbackuppath=\\AcerAspire7720G\gnupg keys backup$\%USERNAME%@%COMPUTERNAME% %DATE% %time::=_%
MKDIR "%gpgbackuppath%"
COPY /B "%APPDATA%\gnupg\*.gpg" "%gpgbackuppath%"
