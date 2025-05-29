#NoEnv
#Warn
#Warn LocalSameAsGlobal, Off

ffExeName := ""
FileReadLine ffExeName, %A_Temp%\ffExeName.txt, 1
If (!ffExeName)
    ffExeName = firefox.exe

GroupAdd firefox, ahk_exe %ffExeName%

If (!A_Args.Length() && WinExist("ahk_group firefox")) {
    If(WinActive())
        WinActivateBottom ahk_group firefox
    Else
        WinActivate
    ExitApp
}

EnvGet LOCALAPPDATA, LOCALAPPDATA

If (!FileExist(sevenmaxPath := LOCALAPPDATA "\Programs\7-max\7max.exe"))
    sevenmaxPath := ""

cmdArgs := FindFirefoxCommand()
If (!cmdArgs)
    Throw Exception("Firefox not found")
mi := cmdArgs.MinIndex()
If (sevenmaxPath) {
    ffPath := """" sevenmaxPath """"
    ; cmdArgs[mi] := """" cmdArgs[mi] """"
    SplitPath % cmdArgs[mi], ffExeName1
} Else {
    ffPath := cmdArgs.RemoveAt(mi)
    SplitPath ffPath, ffExeName1
}
If (ffExeName != ffExeName1) {
    f := FileOpen(A_Temp "\ffExeName.txt", "w"), f.Write(ffExeName1 "`n"), f.Close()
    GroupAdd firefox, ahk_exe %ffExeName1%
}

cmdArgs := ArgsArrayToStr(InsertArgsToCommand(cmdArgs, A_Args*))

ShellRun(ffPath, cmdArgs)
WinWait ahk_group firefox
WinActivate

ExitApp

FindFirefoxCommand() {
    local
    classNames := { "Applications\firefox.exe": ""
        , "firefox-bridge": ""
        , "firefox-private-bridge": "" }
    
    For _, classesRoot in [ "HKEY_CURRENT_USER\Software\Classes"
        , "HKEY_CLASSES_ROOT" ] {
        Loop Reg, %classesRoot%, K
        {
            If (A_LoopRegName ~= "Firefox(HTML|PDF|URL)-\w+")
                classNames[A_LoopRegName] := ""
        }
        For className in classNames {
            RegRead ffCli, %classesRoot%\%className%\shell\open\command
            Try Return CommandWithArgs(ffCli)
        }
    }
    For _, altRegPath in ["HKEY_CURRENT_USER\Software\Clients\StartMenuInternet"] {
        Loop Reg, %altRegPath%, K
        {
            If (!(A_LoopRegName ~= "Firefox-\w+"))
                Continue
            RegRead ffCli, %altRegPath%\%A_LoopRegName%\shell\open\command
            If (ffCli)
                Try Return CommandWithArgs(ffCli)
        }
    }
}

CommandWithArgs(ByRef cliString) {
    ; Parses a command line string and splits it to arguments,
    ; then ensures the first argument is an existing file path
    cmdArgs := ParseCommandLine(cliString)
    If (!cmdArgs)
        Throw Exception("Failed to parse command line",, cliString)
    
    mi := cmdArgs.MinIndex()
    cmdPath := Unquote(cmdArgs[mi])
    If (!FileExist(cmdPath))
        Throw Exception("File not found", cmdPath)
    cmdArgs[mi] := cmdPath
    Return cmdArgs
}

Unquote(ByRef s) {
    ; Removes quotes from the beginning and end of a string
    local
    If (StrLen(s) > 1 && SubStr(s, 1, 1) == """" && SubStr(s, 0) = """")
        return SubStr(s, 2, -1)
    Return s
}

InsertArgsToCommand(argsWithPlaceholder, argsToInsert*) {
    ; Replaces %1 in the argsWithPlaceholder with the argsToInsert,
    ; or appends argsToInsert if %1 is not found
    local
    out := []
    argsNeedInserting := argsToInsert.Length()
    For i, arg in argsWithPlaceholder {
        If (argsNeedInserting && arg == """%1""") {
            out.Push(argsToInsert*)
            argsNeedInserting := ""
        } Else {
            out.Push(arg)
        }
    }
    If (argsNeedInserting) {
        out.Push(argsToInsert*)
    }
    Return out
}

ArgsArrayToStr(ByRef arr) {
    ; Joins command line args array into a single string
    ; quoting args with spaces and special characters
    local
    delimiter := A_Space
    out := ""
    For _, s in arr
        out .= (InStr(s, " ") ? """" s """" : s) . delimiter
    Return SubStr(out, 1, -StrLen(delimiter))
}

#include <ShellRun from Installer>
; #include <ShellRun by Lexikos>
#include <ParseScriptCommandLine>
#include <ParseCommandLine>
