@REM coding:OEM
SET OOoBaseDirectory=c:\Program Files*
FOR /D %%I IN ("%OOoBaseDirectory%") DO SET OOoBaseDirectory=%%~I\
SET OOoDirectory=%OOoBaseDirectory%OpenOffice.org 3\
set OOoSharedDirectory=%OOoDirectory%
SET OOoExecDirectory=%OOoDirectory%program\
SET OOoexecfile="%OOoExecDirectory%soffice.exe"
