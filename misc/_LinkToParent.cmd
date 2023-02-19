@REM coding:OEM
FOR %%I IN (*.*) DO IF NOT "%%~I"=="_LinkToParent.cmd" xln "%%~I" "..\%%~I"
FOR %%I IN ("%COMPUTERNAME%\*.*") DO xln "%%~I" "..\%%~nxI"
