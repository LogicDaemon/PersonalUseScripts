@REM coding:OEM
SET srcpath=%~dp0
SET ftp_proxy=
SET RARopts=-x *.zip -x *.exe -x *.rar -x *.dmg -x *.*bz2 -x *.*z -x *.iso 
CALL wget_the_site.cmd driver.jmicron.com.tw ftp://driver.jmicron.com.tw/
