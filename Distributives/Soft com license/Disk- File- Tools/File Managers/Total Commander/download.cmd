@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%\

IF NOT EXIST "%srcpath%\temp" MKDIR "%srcpath%\temp"
START "" /D "%srcpath%\temp" /WAIT /B wget -ml1 -HD cloudfront.ghisler.com -A.exe http://www.ghisler.com/amazons3.php
