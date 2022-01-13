nprivRun(args*) { ; args for ShellRun: File [, Arguments, Directory, Operation, Show]
    ;Show = args[5]:
    ;0 Open the application with a hidden window.
    ;1 Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
    ;2 Open the application with a minimized window.
    ;3 Open the application with a maximized window.
    ;4 Open the application with its window at its most recent size and position. The active window remains active.
    ;5 Open the application with its window at its current size and position.
    ;7 Open the application with a minimized window. The active window remains active.
    ;10 Open the application with its window in the default state specified by the application.

    ;    XP
    ;	RunString:="""" . args[1] . """ " . args[2]
    ;	Dir := args[3]
    ;	Verb := "*" . args[4]
    ;	If (args[5]!="") {
    ;	    ShowModes := ["Hide","", "Min", "Max", "", "", "Min", ""]
    ;	    ShowMode := ShowModes[args[5]+1]
    ;	}
    ;	Run %Verb% %RunString%, %Dir%, %ShowMode%
    If (args[5]=="") {
	args[5]:=""
    }
    If (args[3]=="") {
	SplitPath % args[3],, dir
	args[3] := dir
    }
    ;skipPaths := {"autohotkey.exe": "", "cmd.exe": ""}
    ;For i, path in args {
    ;    path := Trim(path, """ ")
    ;    SplitPath path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    ;    If (!skipPaths.HasKey(Format("{:L}", OutFileName))) {
    ;        ToolTip % "Starting " OutFileName " via shell and activating the window"
    ;        SetTimer RemoveToolTip, 1000
    ;        break
    ;    }
    ;}
    retval := ShellRun(args*)

    If (args[5] >= 1 && args[5] <= 3) {
	exepath:=args[1]
	WinWait ahk_exe %exepath%, , 3
	If (ErrorLevel) {
            TrayTip %exepath% started but no window found
	} Else {
            Sleep 50
            If (!WinActive()) {
                WinSet AlwaysOnTop, Toggle
                Sleep 5
                WinSet AlwaysOnTop, Toggle
                WinActivate
            }
	}
    }
    return retval
}

#include <ShellRun by Lexikos>
