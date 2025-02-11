;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
If (A_LineFile==A_ScriptFullPath) {
    GetSecretURLs(0)
    FileEncoding CP1
    passwd = %1%
    If(!passwd) {
        InputBox passwd
        If(ErrorLevel)
            ExitApp
        If(!passwd) {
            MsgBox Empty passwords are not allowed.
            ExitApp
        }
    }
    FileAppend % (passwordID := WriteAndShowPassword(passwd)) "`n", *
    If (passwordID)
        Exit
    ExitApp
}

WriteAndShowPassword(ByRef passwd, ByRef fileToAppendPassword := -1) {
    global SystemRoot
    If (!SystemRoot)
        EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server

    passwordID := RecordPassword(passwd)

    Gui Add, Button, xm section gCopypasswordID, Copy (&n)
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy, %passwordID%
    Gui Font
    Gui Add, Button, xm section gCopypasswd, Copy (&p)
    Gui Font, , Consolas
    Gui Add, Edit, ys ReadOnly gSelectAllCopy, %passwd%
    Gui Font
    Gui Add, Button, xm section gReload, Get another code&.
    Gui Show

    If (fileToAppendPassword) {
        If (fileToAppendPassword==-1)
            fileToAppendPassword = %A_Temp%\Numbered Passwords.e\%A_ScriptName%.txt
        SplitPath fileToAppendPassword,, outDir
        FileCreateDir %outDir%
        RunWait %SystemRoot%\System32\cipher.exe /E /S "%outDir%",,Min
        FileAppend %passwd%`n, %fileToAppendPassword%
    }

    return passwordID

    CopypasswordID:
    Copypasswd:
    copyVarName:=SubStr(A_ThisLabel,5)
    Clipboard:=%copyVarName%
    return

    SelectAllCopy:
    EM_SETSEL := 0x00B1
    ;A_Gui, A_GuiControl, A_GuiEvent, and A_EventInfo.
    Gui +LastFound
    ControlFocus %CtrlHwnd%
    ;https://autohotkey.com/board/topic/39793-how-to-select-the-text-in-an-edit-control/
    SendMessage %EM_SETSEL%, 0, -1, %CtrlHwnd%
    ;    MsgBox %ERRORLEVEL%
    return
}

GuiEscape:
GuiClose:
ButtonCancel:
ExitApp

Reload:
Reload

GetPswDbLocation() {
    local
    EnvGet LocalAppData, LOCALAPPDATA
    FileReadLine path, %LOCALAPPDATA%\_sec\Numbered Passwords Path.txt, 1
    Return path
}

GetSecretURLs(which) {
    static urls := ""
    If (!urls) {
        urls := {}
        ; , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        SplitPath A_LineFile, , , , OutNameNoExt
        Loop Read, %A_LineFile%\..\..\pseudo-secrets\%OutNameNoExt%.txt
            If (A_Index)
                urls[A_Index] := A_LoopReadLine
    }
    return urls[which]
}

GenPasswordUID() {
    ;base62: 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
    ;Z85: 0...9, a...z, A...Z, ., -, :, +, =, ^, !, /, *, ?, &, <, >, (, ), [, ], {, }, @, %, $, #
    static alphabet := "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
        , charCount := StrLen(alphabet)

    passwordUID := ""
    Loop 2
    {
        Random rnd, 1, %charCount%
        passwordUID .= SubStr(alphabet, rnd, 1)
    }

    daysSince := ""
    EnvSub daysSince, 20190722, Hours
    Loop 3 ; 85 ^ 3 = 25588 days ~= 70 years
        newDaysSince := daysSince // charCount
            , rem := daysSince - newDaysSince * charCount
            , passwordUID .= SubStr(alphabet, rem+1, 1)
            , daysSince := newDaysSince
    return passwordUID
}

RecordPassword(passwd) {
    ErrorLevel := -1
    Try return FindPassword(passwd, 1)

    Loop
    {
        found := 0, passwordID := GenPasswordUID()
        ; checking dupes
        Loop Parse, % GetURL(GetSecretURLs(1)), `n`r
        {
            If (A_LoopField) {
                Loop Parse, A_LoopField, CSV ; timestamp, passwordID
                {
                    If (A_Index==1) {
                        lasttimestamp := A_LoopField
                    } Else If (A_Index==2) {
                        found := passwordID == A_LoopField
                        break ; only need 2nd column
                    }
                }
                If (found)
                    break
            }
        }
    } Until !found

    While HTTPReq("POST", GetSecretURLs(3)
        , "ID=" UriEncode("'" passwordID) "&pwd=" UriEncode("'" passwd)
        , response := ""
        , {"Content-Type": "application/x-www-form-urlencoded"}) >= 300 {
        MsgBox 53, Posting the password with ID %postID% to the table, Error sending.`n`n[Try %A_Index%`, retry – 5 minutes]`n`n%response%, 300
        IfMsgBox Cancel
            Throw Exception("Cancelled sending the password")
    }

    While !IsObject(file := FileOpen(GetPswDbLocation(), "a-w")) {
        MsgBox 5, %A_ScriptName%, Unable to open the writing params file.`n(autoretry in a minute`, attempt %A_Index%), 60
        IfMsgBox Cancel
            Break
    }

    If (IsObject(file)) {
        written := file.Write("`r`n" passwordID A_Tab passwd)
        file.Close()
        If (written < (StrLen(passwd) + 2) )
            Throw Exception("Password file was opened`, but the password was not completely written",, "(wrote " . written . " bytes).")
        Else
            ErrorLevel := 0
    }

    return passwordID
    ;Try return FindPassword(passwd, 1)
}

FindPassword(passwd, last=0) {
    pswDBfile := GetPswDbLocation()

    If (last) {
        passwordID := 0
        Loop Read, %pswDBfile%
            If (A_LoopReadLine==passwd)
                passwordID := A_Index
            Else If (newpasswordID := CheckPasswordFileLine(A_LoopReadLine, passwd))
                passwordID := newpasswordID
        If (!passwordID)
            Throw Exception("Password not found")
        return passwordID
    } Else {
        Loop Read, %pswDBfile%
            If (A_LoopReadLine==passwd)
                return A_Index
            Else If (newpasswordID := CheckPasswordFileLine(A_LoopReadLine, passwd))
                return newpasswordID
        return 0
    }
}

CheckPasswordFileLine(ByRef line, ByRef passwd) {
    sep := InStr(line, A_Tab)
    If (sep!=6)
        return 0
    return SubStr(line, sep+1) == passwd ? SubStr(line, 1, sep-1) : 0
}

#include %A_LineFile%\..\..\Lib\URIEncodeDecode.ahk
#include %A_LineFile%\..\..\Lib\HTTPReq.ahk
#include %A_LineFile%\..\..\Lib\GetURL.ahk
