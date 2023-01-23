;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#Persistent
#SingleInstance prompt

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

awsDevAccId:="572304703581_AdministratorAccess"

cred := ParseClipCred(Clipboard)
If (cred) {
    Try {
        SaveCredFromClip(cred)
        ExitApp
    }
}
OnClipboardChange(Func("ClipChange"))
MsgBox Waiting for credentials
ExitApp

ParseClipCred(data) { ; returns ["Section Title", "Section Data", "Full Section"]
    local
    credINISection := ""
    Loop Parse, data, `n, `r
        credINISection .= A_LoopField "`n"
    credINISection := SubStr(credINISection, 1, -1)
    credFiltered := RegexMatch(credINISection, "s)^\s*\[(?P<title>.+)\][\s\n]*(.*)", m)
    If (credFiltered && ContainAWSCred(m2)) {
        return [mtitle, m2, credINISection]
    }
}

ClipChange(type) {
    local
    If (type!=1)
        return
    v := ParseClipCred(Clipboard)
    If (!IsObject(v)) {
        ToolTip Clip didn't match aws cred template
        SetTimer ClearTooltip, -3000
        return
    }
    SaveCredFromClip(v)
}

SaveCredFromClip(data) {
    ; data[1]: section title only (without '[' and ']')
    ; data[2]: section contents without title
    ; data[3]: full section text including title. Optional.
    local
    global awsDevAccId

    If (!ContainAWSCred(data[2])) {
        Throw Exception("No AWS cred in data",,data[2])
    }
    
    EnvGet UserProfile, USERPROFILE
    credPath := UserProfile "\.aws\credentials"
    Try {
        If (data[1] = awsDevAccId) {
            IniWriteSectionUnicode(credPath, ["default", data[2]], "UTF-8-RAW")
            exitAfter := true
        }
        IniWriteSectionUnicode(credPath, data, "UTF-8-RAW")
    } Catch e {
        Throw e
    }
    If (FileExist(A_ScriptDir "\update_aws_cred_post_actions.cmd")) {
        ToolTip % "Running update_aws_cred_post_actions.cmd"
        RunWait "%A_ScriptDir%\update_aws_cred_post_actions.cmd",, Min UseErrorLevel
    }
    If (exitAfter)
        ExitApp
    ToolTip % "Wrote Prod AWS cred to profile " data[1] " (see ""%UserProfile%\.aws\credentials""), copying to DEV-FS-05"
}

ContainAWSCred(ByRef data) {
    If (!data)
        return false
    If ( data ~= "i)(^|\n)aws_access_key_id="
      && data ~= "i)(^|\n)aws_secret_access_key="
      && data ~= "i)(^|\n)aws_session_token=" ) {
        return true
    }
    return false
}

ClearTooltip() {
    Tooltip
}

IniWriteSectionUnicode(path, data, encoding="UTF-8") {
    ; data[1]: section title only (without '[' and ']')
    ; data[2]: section contents without title
    ; data[3]: full section text including title. Optional.
    fout := FileOpen(path ".new", "w", encoding)
    If (!IsObject(fout))
        Throw Exception("File wasn't opened",, credPath)
    If (FileExist(path))
        fin := FileOpen(path, "r", encoding)
        IniModifyUnicode(fin, fout, data[1],,, True)
    If (data[3]) {
        fout.WriteLine(data[3])
    } Else {
        fout.WriteLine("[" data[1] "]")
        fout.WriteLine(data[2])
    }
    FileMove %path%, %path%.bak, 1
    FileMove %path%.new, %path%, 1
}

IniModifyUnicode(fin, fout, ByRef iniSection, ByRef key:="", ByRef value:="", remove:=False){
    local
    sectionFound := False, keyPending := True
    
    While (!fin.AtEOF) {
        rl := fin.ReadLine()
        skipOut := False

        If (Trim(rl, "`r`n`t ") && keyPending) {
            If (sectionFound) {
                If (RegExMatch(rl,"^\[.+\][\s]*$")) { ; section header
                    If (remove) {
                        If (key) {
                            ; it must be deleted, but it's not there already
                            Throw Exception("Key not found", 0, key)
                        }
                        ; Else Key not specified, section must be removed, and it already is, and next has begun
                    } Else { ; Not remove
                        fout.WriteLine(key . "=" . value)
                    }
                    sectionFound := False
                    keyPending := False
                } Else { ; Not a section header, must be name=value
                    If ( remove && key=="" ) ; key not specified, removing section
                        Continue ; skip to next, Key will never match, keyPending will become 0 only at end of section
                    
                    If (key) {
                        currentKey := Trim(SubStr(rl, 1, InStr(rl, "=")-1))
                        If (currentKey = key) {
                            keyPending := False
                            If (remove)
                                Continue ; to skip FileAppend
                            Else
                                fout.WriteLine(key . "=" . value)
                                skipOut := True
                            ; TODO: overwrite it return SubStr(rl, NameValueSplitPos+2)
                        }
                    }
                }
            } Else If (Trim(rl, "`r`n`t ") = "[" iniSection "]") {
                sectionFound := True
                If ( remove && key=="" ) ; Removing section, because key not specified
                    Continue
            }
        }
        If (!skipOut)
            fout.Write(rl)
    }
    
    If (!remove && keyPending) { ; Section not found in the source file
        fout.WriteLine("`n[" iniSection "]")
        fout.WriteLine(key "=" value)
    }
}
