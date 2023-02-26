;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

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

IniModifyUnicode(ByRef Filename, ByRef IniSection, ByRef Key:="", ByRef Value:="", Remove:=False){
    local
    sectionFound := False, keyPending := True
    
    IfNotExist %Filename%
	Throw Exception("File not exist", 0, Filename)
    IfExist %Filename%.new
	FileDelete %Filename%.new
    Loop Read, %Filename%, %Filename%.new
    {
	OutputLine := A_LoopReadLine

	If (keyPending) {
	    If (sectionFound) {
		If (RegExMatch(A_LoopReadLine,"^\[.+\][\s]*$")) { ; section header
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
		    If ( Remove && Key=="" ) ; key not specified, removing section
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
	    } Else {
		If (A_LoopReadLine = "[" IniSection "]") {
		    sectionFound := True
		    If ( Remove && Key=="" ) ; Removing section, because key not specified
			Continue
		}
	    }
	}
	FileAppend %OutputLine%`n
    }
    
    If (keyPending) ; Section not found
	FileAppend [%IniSection%]`n%Key%=%Value%`n, %Filename%.new
    
    FileMove %Filename%,%Filename%.%A_Now%.bak
    FileMove %Filename%.new,%Filename%,1
}
