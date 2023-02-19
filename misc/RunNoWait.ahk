#NoEnv
#NoTrayIcon

SplitPath 1,,,ext 
If (ext = "ahk")
    Run % """" A_AhkPath """ " ParseScriptCommandLine()
Else If (ext = "cmd" || ext = "bat")
    Run % comspec " /C """ ParseScriptCommandLine() """",, Min
Else
    Run % ParseScriptCommandLine()
