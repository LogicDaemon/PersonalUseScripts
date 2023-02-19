SETLOCAL ENABLEEXTENSIONS
SET archivename=_html_and_doc.rar

START "" /B /WAIT /D "%~dp0" rar x %archivename%
START "" /B /WAIT /D "%~dp0" wget -m -l 3 -H -e robots=off --progress=dot:giga -o .log -Xforums http://antirootkit.com/software/
START "" /B /WAIT /D "%~dp0" rar m -y -u -as -cfg- -m5 -s -tsm0 -r -x*.zip -x*.rar -x*.exe -x*.7z -- %archivename%
