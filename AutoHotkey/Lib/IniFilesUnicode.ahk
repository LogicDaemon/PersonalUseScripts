;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

EnvGet USERPROFILE,USERPROFILE

IniReadUnicode(Filename, IniSection, Key){
    local
    sectionFound:=False
    
    IfNotExist %Filename%
        Throw Exception("File not exist", 0, Filename)
    Loop Read, %Filename%
    {
        If sectionFound {
            If (RegExMatch(A_LoopReadLine,"^\[.+\]$")) { ; Next section begin
                Break
            } Else {
                NameValueSplitPos:=InStr(A_LoopReadLine, "=")
                If ( Trim(SubStr(A_LoopReadLine, 1, NameValueSplitPos-1)) = Trim(Key) )
                    return SubStr(A_LoopReadLine, NameValueSplitPos+1)
            }
        } Else {
            If A_LoopReadLine = [%IniSection%]
                sectionFound:=True
        }
    }

    If sectionFound
        Throw Exception("Corresponding key not found inside section", 0, Key)
    Else
        Throw Exception("section not found", -1, IniSection)
}

IniReadSectionUnicode(Filename, IniSection){
    local
    sectionFound:=False
    
    IfNotExist %Filename%
        Throw Exception("File not exist", 0, Filename)
    Loop Read, %Filename%
    {
        OutputLine := A_LoopReadLine

        If sectionFound {
            If (RegExMatch(A_LoopReadLine,"^\[.+\]$")) ; Next section begin
                break
            Else ; Not a section header, section contents
                SectionContents .= A_LoopReadLine . "`n"
        } Else {
            If A_LoopReadLine = [%IniSection%]
                sectionFound:=True
        }
    }
    
    If (!SectionContents)
        Throw Exception("section not found", -1, IniSection)

    return SectionContents
}

IniWriteUnicode(Filename, IniSection, Key, Value) {
    Return IniModifyUnicode(Filename, IniSection, Key, Value)
}

IniWriteSectionUnicode(Filename, IniSection, SectionContents) {
    IniDeleteSectionUnicode(Filename, IniSection)
    FileAppend [%IniSection%]`n%SectionContents%`n, %Filename%
}

IniDeleteKeyUnicode(Filename, IniSection, Key) {
    Return IniModifyUnicode(Filename, IniSection, Key,, True)
}

IniDeleteSectionUnicode(Filename, IniSection){
    Return IniModifyUnicode(Filename, IniSection,,, True)
}

;IniEnumSectionsUnicode(Filename){
;}

;IniEnumKeysUnicode(Filename, IniSection){
;}

IniModifyUnicode(ByRef Filename, ByRef IniSection, ByRef Key:="", ByRef Value:="", Remove:=False, ByRef Backup:=True){
    local
    sectionFound := False, keyPending := True

    If (FileExist(Filename)) {
        tmpPath := Filename ".tmp"
        If FileExist(tmpPath)
            FileDelete % tmpPath
        Loop Read, %Filename%, %tmpPath%
        {
            OutputLine := A_LoopReadLine
            trOutputLine := Trim(OutputLine)
    
            If (keyPending) {
                If (sectionFound) { ; only when the required section is found
                    If (SubStr(trOutputLine, 1, 1) == "[" && SubStr(trOutputLine, 0) == "]") { ; another section header
                        If (Remove) {
                            If (Key) {
                                ; it must be deleted, but it's not there already
                                Throw Exception("Key not found", 0, Key)
                            }
                            ; Else Key not specified, section must be removed, and it already is, and next has begun
                        } Else { ; Not Remove
                            OutputLine := Key . "=" . Value . "`n" . OutputLine
                        }
                        sectionFound := False
                        keyPending := False
                    } Else { ; Not a section header, must be name=value
                        If ( Remove && Key=="" ) ; no key specified, removing section
                            Continue ; skip to next, Key will never match, keyPending will become 0 only at end of section
                        
                        currentKey := Trim(SubStr(A_LoopReadLine, 1, InStr(A_LoopReadLine, "=")-1))
                        If (currentKey = Key) {
                            keyPending := False
                            If (Remove)
                                Continue ; to skip FileAppend
                            Else
                                OutputLine = %Key%=%Value%
                            ; TODO: overwrite it return SubStr(A_LoopReadLine, NameValueSplitPos+2)
                        }
                    }
                } Else If (trOutputLine == "[" IniSection "]") { ; the required section is not yet found or already processed
                    sectionFound := True
                    If ( Remove && Key=="" ) ; When removing section, because no key specified
                        Continue
                }
            }
            ; All unmodified lines are copied
            FileAppend %OutputLine%`n
        }
    } Else {
        If (Remove)
            Throw Exception("File not exist", 0, Filename)
        tmpPath := Filename
        Backup := False
    }
    
    If (keyPending) { ; Value is not yet written
        ; sectionFound=True here means the required section is the last in the file
        prefix := sectionFound ? "" : "[" IniSection "]`n" ; section is not found
        FileAppend % prefix Key "=" Value "`n", %tmpPath%
    }
    If (Backup) {
        If (Backup == True)
            Backup = Filename "." A_Now ".bak"
        FileMove %Filename%,%Backup%
    }
    If (tmpPath != Filename)
        FileMove %tmpPath%,%Filename%,1
}
