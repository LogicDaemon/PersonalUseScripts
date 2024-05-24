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

cmdArgs := FindFirefoxCommand()
If (!cmdArgs)
    Throw Exception("Firefox not found")
mi := cmdArgs.MinIndex()
ffPath := cmdArgs.RemoveAt(mi)
cmdArgs := InsertArgsToCommand(cmdArgs, A_Args*)

SplitPath ffPath, ffExeName1
If (ffExeName != ffExeName1) {
    FileDelete %A_Temp%\ffExeName.txt
    FileAppend % ffExeName1 "`n", %A_Temp%\ffExeName.txt
    GroupAdd firefox, ahk_exe %ffExeName1%
}

; A_ProgramFiles "\Mozilla Firefox\firefox.exe"
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
    argsNeedInserting := argsToInsert.Length()
    For i, arg in argsWithPlaceholder {
        If (arg == """%1""") {
            ; ffArgs.InsertAt(Pos, Value1, [Value2, ... ValueN])
            argsWithPlaceholder.Delete(i)
            If (argsNeedInserting) {
                argsWithPlaceholder.InsertAt(i, argsToInsert*)
                argsNeedInserting := False
            }
        }
    }
    If (argsNeedInserting) {
        argsWithPlaceholder.Push(argsToInsert*)
    }
    Return argsWithPlaceholder
}

#include <ShellRun from Installer>
#include <ParseScriptCommandLine>
#include <ParseCommandLine>
