@REM coding:OEM
(
SETLOCAL ENABLEEXTENSIONS
SET srcpath=%~dp0
)
(
IF "%srcpath%"=="" SET srcpath=%CD%\

SET UIDAdministrators=S-1-5-32-544;s:y
SET UIDSYSTEM=S-1-5-18;s:y
SET UIDEveryone=S-1-1-0;s:y

SET baseDir=d:\Users\Public\Pictures
)
IF NOT EXIST "%baseDir%" (
    ECHO Папка "%baseDir%" не существует.
    ECHO Укажите базовую папку, в которой будет создана папка Сканированное:
    SET /P baseDir=
)
(
MKDIR "%baseDir%\Сканированное"

NET SHARE Сканированное /DELETE
NET SHARE Сканированное="%baseDir%\Сканированное" /GRANT:Everyone,Read
NET SHARE Сканированное="%baseDir%\Сканированное" /GRANT:Все,Read
NET SHARE Сканированное="%baseDir%\Сканированное"

"c:\SysUtils\SetACL.exe" -on "%baseDir%\Сканированное" -ot file -actn setowner -ownr "n:%UIDAdministrators%" -actn setprot -op "dacl:p_nc;sacl:np" -actn clear -clr dacl -actn rstchldrn -rst dacl -actn ace -ace "n:%UIDAdministrators%;p:full;i:sc,so" -actn ace -ace "n:%UIDSYSTEM%;p:full;i:io,so" -actn ace -ace "n:%UIDEveryone%;p:change,FILE_DELETE_CHILD;i:sc" -actn ace -ace "n:%UIDEveryone%;p:write,read,FILE_DELETE_CHILD,DELETE;i:io,so" 
)
