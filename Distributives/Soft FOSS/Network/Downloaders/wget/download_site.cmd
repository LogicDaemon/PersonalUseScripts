@REM coding:OEM
SET srcpath=%~dp0
IF "%srcpath%"=="" SET srcpath=%CD%
SET RARopts=-x*.zip -x*.exe

CALL wget_the_site users.ugent.be http://users.ugent.be/~bpuype/wget/ http://users.ugent.be/~bpuype/wget/wget.exe
CALL wget_the_site www.gnu.org http://www.gnu.org/software/wget/manual/wget.html
CALL wget_the_site xoomer.virgilio.it http://xoomer.virgilio.it/hherold/
