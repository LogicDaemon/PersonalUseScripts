;required for AOMEI Backupper because it garbles the CLI arguments
#NoEnv
FileEncoding UTF-8

;EnvGet LocalAppData,LOCALAPPDATA
;EnvGet SystemRoot,SystemRoot
;MsgBox % ParseScriptCommandLine() "`n" A_WorkingDir
RunWithBackgroundPriority("compact.exe /c /exe:lzx " ParseScriptCommandLine())
ExitApp

#include <RunWithBackgroundPriority>
