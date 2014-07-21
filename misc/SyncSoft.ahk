#NoEnv

unisonexe:="c:\SysUtils\unison\Unison-2.40.61 Text.exe"

SetEnv UNISONLOCALHOSTNAME,logicdaemonhome

Run "%unisonexe%" -socket 10355
Sleep 300
RunWait "%unisonexe%" Distributives -path Soft -killserver
