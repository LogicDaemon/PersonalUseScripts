;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

GetKnownFolderByGUID(ByRef folderGUID) { ;http://www.autohotkey.com/forum/viewtopic.php?t=68194 
    VarSetCapacity(mypath,(A_IsUnicode ? 2 : 1)*1025) 
    
    SetGUID(rfid, folderGUID)
    r := DllCall("Shell32\SHGetKnownFolderPath", "UInt", &rfid, "UInt", 0, "UInt", 0, "UIntP", mypath)
    return (r or ErrorLevel) ? 0 : StrGet(mypath,,"UTF-16") 
} 

SetGUID(ByRef GUID, String) { 
    VarSetCapacity(GUID, 16, 0) 
    StringReplace,String,String,-,,All 
    NumPut("0x" . SubStr(String, 2,  8), GUID, 0,  "UInt")   ; DWORD Data1 
    NumPut("0x" . SubStr(String, 10, 4), GUID, 4,  "UShort") ; WORD  Data2 
    NumPut("0x" . SubStr(String, 14, 4), GUID, 6,  "UShort") ; WORD  Data3 
    Loop, 8 
	NumPut("0x" . SubStr(String, 16+(A_Index*2), 2), GUID, 7+A_Index,  "UChar")  ; BYTE  Data4[A_Index] 
} 
