;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-16

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

iniPath := (A_Args[1] ? A_Args[1]
    : FileExist("..\TOTALCMD64.EXE") || FileExist("..\TOTALCMD.EXE") ? "..\wincmd.ini"
    : FileExist("wincmd.ini") ? "wincmd.ini"
    : "")

If (!iniPath) {
    MsgBox, 16, Error, wincmd.ini not found.`nPlease specify the path to wincmd.ini as a parameter.
    ExitApp 1
}

SplitPath iniPath, OutFileName, OutDir
If (OutFileName != "wincmd.ini") {
    MsgBox, 16, Error, Ini file name must be wincmd.ini.`nYou specified: %OutFileName%
    ExitApp 1
}
If (FileExist(iniPath)) {
    UpdateConfig(iniPath)
} Else If (FileExist(A_AppData "\GHISLER\wincmd.ini")) {
    If (InStr(FileExist(OutDir "\config"), "D")) {
        FileCopy A_AppData "\GHISLER\*.*", %OutDir%\config\
    } Else {
        FileCopyDir %A_AppData%\GHISLER\, %OutDir%\config
    }
    If (!FileExist(OutDir "\config\portable"))
        FileCopyDir %A_AppData%\GHISLER\%A_ComputerName%, %OutDir%\config\portable
    UpdateConfig(OutDir "\config\wincmd.ini")
    If (FileExist(OutDir "\wincmd.ini"))
        FileMove %OutDir%\wincmd.ini, %OutDir%\wincmd.ini.bak
    RunWait %comspec% /C "MKLINK /H wincmd.ini config\wincmd.ini", %OutDir%, Min
    If (ErrorLevel)
        FileMove %OutDir%\config\wincmd.ini, %OutDir%\wincmd.ini, 1
    ; savedWorkDir := A_WorkingDir
    ; SetWorkingDir %OutDir%
    ; CreateLinks("config\*.*", ".")
    ; SetWorkingDir %savedWorkDir%
} Else {
    MsgBox, 16, Error, wincmd.ini not found in the program directory or in %A_AppData%\GHISLER.
    ExitApp 1
}
ExitApp

UpdateConfig(ByRef iniPath) {
    Local
    ; UseIniInProgramDir=
    ; 0 This variable will only be read if the wincmd.ini is located in the same dir as the program.
    ; It is the sum of the following values:
    ; 1: Use wincmd.ini in program dir if no other location is set via registry or parameters
    ; 2: Use wcx_ftp.ini in program dir if no other location is set via registry or parameters
    ; 4: Override registry settings (but not command line parameters)
    updatedUseIniInProgramDir := False
    FileDelete %iniPath%.tmp
    Loop Read, %iniPath%, %iniPath%.tmp
    {
        line := Trim(A_LoopReadLine)
        If (line ~= "^\[.+\]$") {
            FileAppend %A_LoopReadLine%`n
            section := SubStr(line, 2, -1)
            Continue
        }
        commentLoc := InStr(line, ";")
        If (commentLoc) {
            If (commentLoc == 1) {
                If (!updatedUseIniInProgramDir
                    && RegExMatch(A_LoopReadLine, "^\s*;\s*UseIniInProgramDir\s*=\s*(.*)", match)) {
                    FileAppend UseIniInProgramDir=7 `; %match1%`n
                    updatedUseIniInProgramDir := True
                    Continue
                }
                FileAppend %A_LoopReadLine%`n
                Continue
            }
            comment := SubStr(line, commentLoc)
            line := Trim(SubStr(line, 1, commentLoc - 1))
        } Else {
            comment := ""
        }
        equalsPos := InStr(line, "=")
        If (!equalsPos) {
            FileAppend %A_LoopReadLine%`n
            Continue
        }
        key := RTrim(SubStr(line, 1, equalsPos - 1))
        value := StrReplace(LTrim(SubStr(line, equalsPos + 1)), "%APPDATA%\GHISLER", "%COMMANDER_PATH%\config")
        If (section = "Configuration" && key = "UseIniInProgramDir") {
            FileAppend UseIniInProgramDir=7%comment%`n
            updatedUseIniInProgramDir := True
            Continue
        }
        If (!InStr(value, "%")) {
            FileAppend %A_LoopReadLine%`n
            Continue
        }

        inVarName := True ; inverted first inside the loop
        filteredValue := ""
        Loop Parse, value, `%
        {
            inVarName := !inVarName
            If (!inVarName) {
                filteredValue .= A_LoopField
                Continue
            }
            If () {
                filteredValue .= "%" A_LoopField "%"
                Continue
            }
            If (A_LoopField == "" ; %%
                || A_LoopField = "COMMANDER_PATH" ; %COMMANDER_PATH%
                || A_LoopField ~= "^[0-9]+" ) { ; %12xcvzxvz %1"
                filteredValue .= "%" A_LoopField "%"
                Continue
            }
            If (A_LoopField == "COMPUTERNAME") {
                filteredValue .= "portable"
                Continue
            }
            EnvGet varValue, %A_LoopField%
            If (ErrorLevel) {
                filteredValue .= "%" A_LoopField "%"
                Continue
            }
            filteredValue .= InStr(varValue, ":\") ? "%COMMANDER_PATH%" : ("%" A_LoopField "%")
        }
        If (inVarName)
            filteredValue := SubStr(filteredValue, 1, -1) ; remove last %
        FileAppend %key%=%filteredValue%%comment%`n
    }
    If (!updatedUseIniInProgramDir)
        IniWrite 7, %iniPath%.tmp, Configuration, UseIniInProgramDir
    FileMove %iniPath%, %iniPath%.bak
    FileMove %iniPath%.tmp, %iniPath%, 1
}

CreateLinks(Source, Destination) {
    Loop, Files, %Source%, DF
    {
        If (A_LoopFileAttrib ~= "D")
            flag = /D
        Run %comspec% /C "MKLINK %flag% """ Destination "\" A_LoopFileName """ """ A_LoopFileFullPath """ || PAUSE", %A_WorkingDir%, Min
    }
}
