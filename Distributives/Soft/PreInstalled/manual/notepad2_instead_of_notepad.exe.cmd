@(REM coding:CP866
REM by LogicDaemon <www.logicdaemon.ru>
REM This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
SETLOCAL ENABLEEXTENSIONS
    FOR /F "usebackq tokens=1 delims=[]" %%I IN (`%SystemRoot%\System32\find.exe /n "-!!! key list marker -" "%~f0"`) DO @SET "ftypesSkipLines=skip=%%I"

    SET "IsAdmin="
    IF NOT DEFINED ForceNonAdmin %SystemRoot%\System32\fltmc.exe >nul 2>&1 && SET "IsAdmin=1"
    
    IF DEFINED IsAdmin (
        SET "RegRoot=HKEY_CLASSES_ROOT"
    ) ELSE (
        SET "RegRoot=HKEY_CURRENT_USER\Software\Classes"
    )
    
    REM Current user-only
    IF NOT DEFINED IsAdmin FOR %%A IN ("%LOCALAPPDATA%\Programs\notepad2\notepad2.exe" "%LOCALAPPDATA%\Programs\Total Commander\Notepad2.exe") DO @IF EXIST %%A (
        SET "notepad2path=%%~A"
        GOTO :foundnotepad2
    )
    
    REM Everyone
    FOR %%A IN ("%ProgramFiles%\notepad2\notepad2.exe" "%ProgramFiles%\notepad2-mod\notepad2.exe") DO @IF EXIST %%A (
        SET "notepad2path=%%~A"
        GOTO :foundnotepad2
    )
    FOR %%A IN ("%ProgramFiles(x86)%\notepad2\notepad2.exe" "%ProgramFiles(x86)%\notepad2-mod\notepad2.exe") DO @IF EXIST %%A (
        SET "regkey=/reg:32"
        SET "notepad2path=%%~A"
        GOTO :foundnotepad2
    )
    ECHO notepad2.exe not found
    EXIT /B 1
)
:foundnotepad2
@(
    FOR /F "usebackq %ftypesSkipLines% tokens=*" %%A IN ("%~f0") DO REG ADD "%RegRoot%\%%~A" /ve /d "\"%notepad2path%\" \"%%1\"" /F %regkey%
    REG ADD "%RegRoot%\*\OpenWithList\notepad2.exe" /F %regkey%
    IF DEFINED IsAdmin REG ADD "HKEY_CLASSES_ROOT\SystemFileAssociations\text\OpenWithList\Notepad2.exe" /F %regkey%
    EXIT /B
)

REM -!!! key list marker -
Applications\Notepad2.exe\shell\edit\command
Applications\Notepad2.exe\shell\open\command
SystemFileAssociations\text\shell\edit\command
SystemFileAssociations\text\shell\open\command
batfile\shell\edit\command
cmdfile\shell\edit\command
inffile\shell\open\command
inifile\shell\open\command
JSEFile\Shell\Edit\Command
JSFile\Shell\Edit\Command
Microsoft.PowerShellData.1\Shell\Open\Command
Microsoft.PowerShellModule.1\Shell\Open\Command
Microsoft.PowerShellScript.1\Shell\Open\Command
regfile\shell\edit\command
scriptletfile\Shell\Open\command
tsv_auto_file\shell\edit\command
tsv_auto_file\shell\open\command
VBEFile\Shell\Edit\Command
VBSFile\Shell\Edit\Command
WSFFile\Shell\Edit\Command
zapfile\shell\open\command
