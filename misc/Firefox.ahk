#NoEnv
#Warn
#Warn LocalSameAsGlobal, Off

ffExeName := ""
FileReadLine ffExeName, %A_Temp%\ffExeName.txt, 1
restart:
If (ffExeName) {
    GroupAdd firefox, ahk_exe %ffExeName%
}

If (!A_Args.Length() && WinExist("ahk_group firefox")) {
    If(WinActive())
        WinActivateBottom ahk_group firefox
    Else
        WinActivate
    ExitApp
}

cmdArgs := FindFirefoxCommand()
If (!cmdArgs)
    Throw Exception("Firefox not found")
mi := cmdArgs.MinIndex()
ffPath := Unquote(cmdArgs.RemoveAt(mi))
If (A_Args.Length())
    cmdArgs := FillCommandArgs(cmdArgs, A_Args, """%1""", ["-osint", "-url"])
Else
    cmdArgs := RemoveElements(cmdArgs, ["-osint", "-url", """%1"""])

SplitPath ffPath, ffExeName1
If (ffExeName != ffExeName1) {
    f := FileOpen(A_Temp "\ffExeName.txt", "w"), f.Write(ffExeName1), f.Close()
    GroupAdd firefox, ahk_exe %ffExeName1%
    If (!A_Args.Length()) {
        ffExeName := ffExeName1
        GoTo restart
    }
}

; A_ProgramFiles "\Mozilla Firefox\firefox.exe"
ShellRun(ffPath, ArgsArrayToStr(cmdArgs))
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
    Return cmdArgs
}

Unquote(ByRef s) {
    ; Removes quotes from the beginning and end of a string
    local
    If (StrLen(s) > 1 && SubStr(s, 1, 1) == """" && SubStr(s, 0) = """")
        return SubStr(s, 2, -1)
    Return s
}

FillCommandArgs(argsWithPlaceholder, ByRef argsToInsert, placeholder := """%1""", removeArgs := "") {
    ; Replaces placeholder in the argsWithPlaceholder with the argsToInsert,
    ; or appends argsToInsert if placeholder is not found;
    ; removes args from the argsWithPlaceholder if they are in removeArgs.
    local
    out := []

    if (IsObject(removeArgs)) {
        removeArgsDict := {}
        For _, v in removeArgs
            removeArgsDict[v] := ""
    }

    argsNeedInserting := argsToInsert.Length()
    For i, arg in argsWithPlaceholder {
        If (argsNeedInserting && arg == placeholder) {
            out.Push(argsToInsert*)
            argsNeedInserting := False
        } If (!removeArgsDict.HasKey(arg)) {
            out.Push(arg)
        }
    }
    If (argsNeedInserting) {
        out.Push(argsToInsert*)
    }
    Return out
}

RemoveElements(ByRef arr, ByRef elements) {
    ; Removes elements from an array
    local
    elementsDict := {}
    For _, v in elements
        elementsDict[v] := ""
    remains := 0
    For i, v in arr
        If (elementsDict.HasKey(v)) {
            ; arr.Delete(i) breaks iteration, some elements get skipped
            arr[i] := ""
        } Else {
            remains++
        }
    out := []
    If (remains)
        For _, v in arr
            If (v) {

                MsgBox % v
                out.Push(v)
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
        If (Trim(s))
            out .= (s ~= "^[\w\-\.\\/]+$" ? s : """" s """") . delimiter
    Return SubStr(out, 1, -StrLen(delimiter))
}

#include <ShellRun from Installer>
#include <ParseScriptCommandLine>
#include <ParseCommandLine>
