;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

If (A_Args.Length()) {
    For i, arg in A_Args {
        OpenURL(arg)
    }
    ExitApp
}

AssociationRegPaths := { "httpUCProgId": ["HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice", "ProgId"]
    , "httpsUCProgId": ["HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice", "ProgId"] }
; , "httpCommand": ["HKEY_CLASSES_ROOT\http\shell\open\command", ""]
; , "httpsCommand": ["HKEY_CLASSES_ROOT\https\shell\open\command", ""] }

scriptOpenCommand = "%A_AhkPath%" "%A_ScriptFullPath%" "`%1"

ScriptAssociations := { "httpUCProgId": "openURLahk"
    , "httpsUCProgId": "openURLahk" }
; , "httpCommand": scriptOpenCommand
; , "httpsCommand": scriptOpenCommand }


StartMenuRegPath := "Software\Clients\StartMenuInternet\OpenURLahk"
BackupRegPath := "HKEY_CURRENT_USER\Software\LogicDaemon\OpenURL\Backup"
WhitelistDir := LocalAppData "\LogicDaemon\OpenURL"
WhitelistPath := WhitelistDir "\Whitelist.txt"

BackupState := CheckBackup()
For AssocType, AssocValue in GetCurrentAssociation()
    If (AssocType ~= "^https?UCProgId$")
        Break

Gui Add, Text, Section, Current association:
Gui Add, Edit, ys vAssocValue ReadOnly, %AssocValue% [%AssocType%]
Gui Add, Text, xm Section, Backup:
Gui Add, Edit, ys vBackupStateValue ReadOnly, % BackupState[2] ? BackupState[2] : BackupState[1] ? "Current" : "Missing"

Gui Add, Button, xm Section gBackup, Backup
Gui Add, Button, ys gGuiButtonAssociate, Associate
Gui Add, Button, ys gRestoreBackup, Restore
Gui Add, Button, xm Section gEditWhitelist, Edit Whitelist

Gui Show

Exit

GuiClose:
GuiEscape:
ExitApp

GuiButtonAssociate:
    If (!CheckBackup()[1])
        Backup()
    Associate()
Return

Backup() {
    Local
    Global BackupRegPath

    current := GetCurrentAssociation()
    currentBackup := CheckBackup(current)
    If (currentBackup[1]) {
        diffs := currentBackup[2]
        If (diffs) {
            MsgBox 0x24, %A_ScriptName%, The current backup already exists and differs from the new one.`n%diffs%Overwrite?
            IfMsgBox No
                Return
        }
    }

    For k, v in current
        RegWrite REG_SZ, %BackupRegPath%, %k%, %v%
    ToolTip The current browser association has been backed up.
    Sleep 1000
    ToolTip
}

CheckBackup(current := "") {
    ; The argument is an object with the current association keys and values
    ; (keys should be in AssociationRegPaths).
    ; If the argument is empty, the current associations will be read from registry.
    ; Returns: [presence, diff]
    ;   presence is a boolean value:
    ;     True if backup exists and matches current association
    ;     False if backup backup does not exist or misses some values
    ;   diff is a string
    ;     with the differences if backup exists but does not match

    Local
    Global BackupRegPath
    current := current == "" ? GetCurrentAssociation() : current
    diff := ""
    haveFull := True
    For k, v in current {
        RegRead pv, %BackupRegPath%, %k%
        If (ErrorLevel || !pv)
            haveFull := False
        Else If (pv != v)
            diff .= k ": " pv " → " v "`n"
    }
    Return [haveFull, diff]
}

RestoreBackup() {
    Local
    Global BackupRegPath, AssociationRegPaths
    If (!CheckBackup()[1]) {
        MsgBox 0x10, %A_ScriptName%, Backup is missing or incomplete.
        Return
    }

    Loop Reg, %BackupRegPath%
    {
        RegRead value
        dst := AssociationRegPaths[A_LoopRegName]
        If (!dst)
            Continue
        RegWrite REG_SZ, % dst[1], % dst[2], %value%
    }

    ; Force Windows to acknowledge the change
    DllCall("shell32\SHChangeNotify", "uint", 0x08000000, "uint", 0, "int", 0, "int", 0)

    ToolTip Original browser association has been restored.
    Sleep 1000
    ToolTip
}

GetCurrentAssociation() {
    Local
    Global AssociationRegPaths, ScriptAssociations
    ; Get http URL association
    current := {}
    For n, v in AssociationRegPaths {
        rp := v[1]
        vn := v[2]
        RegRead value, %rp%, %vn%
        If (ErrorLevel)
            continue
        current[n] := value
        If (n ~= "^https?UCProgId$") {
            RegRead command, HKEY_CLASSES_ROOT\%value%\shell\open\command,
            current["command_" n] := command
        }
    }

    present := 0
    missing := ""
    For k in ScriptAssociations
        If (current[k])
            present++
        Else
            missing .= "`n" k
    If (!present) {
        MsgBox 0x10, %A_ScriptName%, Could not determine the current browser association.
    } Else If (missing) {
        MsgBox 0x10, %A_ScriptName%, The following keys are missing in the current browser association:%missing%
    }

    return current
}

Associate() {
    Local
    Global ScriptAssociations, scriptOpenCommand, StartMenuRegPath

    ; Create our own ProgId and register capabilities
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\openURLahk\shell\open\command,, %scriptOpenCommand%

    ; Register the app in the Default Programs interface
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\openURLahk,,Open URL Handler
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\openURLahk\DefaultIcon,, %A_AhkPath%,0
    ; Add these commands for protocol handlers
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\openURLahk\URL Protocol,,
    
    ; Set up the icon for the Start Menu entry
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\DefaultIcon,, %A_AhkPath%,0
    
    ; Register Application Capabilities
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities,, URL Handler
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities, ApplicationDescription, Custom URL handler that can filter URLs
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities, ApplicationName, Open URL Handler
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities\URLAssociations, http, openURLahk
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities\URLAssociations, https, openURLahk
    
    ; Fix the StartMenu key
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\Capabilities, StartMenuInternet, OpenURLahk
    
    ; Set up command for the app
    RegWrite REG_SZ, HKEY_CURRENT_USER\%StartMenuRegPath%\shell\open\command,, %scriptOpenCommand%

    ; Register with Default Programs
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\RegisteredApplications, OpenURLahk, %StartMenuRegPath%\Capabilities

    ; Force Windows to acknowledge the changes
    DllCall("shell32\SHChangeNotify", "uint", 0x08000000, "uint", 0, "int", 0, "int", 0)

    ; Open Windows settings to the Default Apps page
    Run, ms-settings:defaultapps

    ; Prompt user to manually set the handler
    MsgBox, 0x40, %A_ScriptName%, The script has been registered as a potential URL handler.`n`nYou now need to set it as the default handler manually:`n1. Windows Settings will open to "Choose default apps"`n2. Scroll down and click on "Choose default apps by protocol"`n3. Find HTTP and HTTPS, and select "Open URL Handler"`n`nYou now need to set it as the default handler manually:`n1. Windows Settings will open to "Choose default apps"`n2. Scroll down and click on "Choose default apps by protocol"`n3. Find HTTP and HTTPS, and select "Open URL Handler"
}

OpenURL(ByRef url) {
    ; Check if URL should be blocked
    If (!Whitelisted(url)) {
        MsgBox 0x23, %A_ScriptName%, Opening non-whitelisted %url%`n`nAdd to whitelist?
        IfMsgBox Cancel
            Return
        IfMsgBox Yes
        {
            If (!FileExist(WhitelistDir))
                FileCreateDir, %WhitelistDir%
            FileAppend %url%`n, %WhitelistPath%
        }
    }

    ; Open the URL in the default browser
    Run %AssocValue% "%url%"
    Gui Add, Text, Section, Opening URL:
    Gui Add, Edit, ys ReadOnly, %url%
    Gui Show
}

Whitelisted(ByRef url) {
    Local
    Global WhitelistPath
    Loop Read, %WhitelistPath%
    {
        If (A_LoopReadLine == url
            || !InStr(A_LoopReadLine, "/")
            && url ~= "^(\w+://)?\Q" StrReplace(A_LoopReadLine, "\E", "\\E") "\E\b")
            Return True
    }
}

EditWhitelist() {
    Local
    Global WhitelistPath
    If (!FileExist(WhitelistDir))
        FileCreateDir %WhitelistDir%
    Run *Edit "%WhitelistPath%"
}
