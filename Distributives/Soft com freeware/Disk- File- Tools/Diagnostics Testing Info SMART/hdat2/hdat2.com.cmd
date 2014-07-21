@ECHO OFF

SET srcpath=%~dp0

SET RARopts=-x*.zip -x*.rar -x*.exe

CALL wget_the_site.cmd www.hdat2.com
