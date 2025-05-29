;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

repoToVarName := { "https://bitbucket.org/anymeeting/media-drachtio-freeswitch-docker.git": "DockerCommit"
    ,"https://bitbucket.org/anymeeting/media-drachtio-freeswitch-modules.git": "ModulesCommit"
    ,"https://bitbucket.org/anymeeting/freeswitch.git": "FreeswitchCommit"
    ,"https://bitbucket.org/anymeeting/asr-opensips.git": "OpenSIPSCommit" }
freezeUpdates := true

PrevReleaseTag := A_Args[1]
if (PrevReleaseTag == "")
    PrevReleaseTag := "asr-release-"

DrawGUI()
OnClipboardChange("ParseClipboardURLs")

Exit

DrawGUI() {
    Global
    Local textW := 120
        , editW := 300
        , resultW := textW + editW
        , resultsPlaceholder := ""

    Gui Add, Text, xm Section w%textW%, Previous Release tag:
    Gui Add, Edit, ys vPrevReleaseTag gUpdateOutputs w%editW%, %PrevReleaseTag%

    For _, destVar in repoToVarName {
        Gui Add, Text, xm Section w%textW%, %destVar%:
        Gui Add, Edit, ys v%destVar% gUpdateOutputs w%editW%, % %destVar%
    }

    Loop % repoToVarName.Count()
        resultsPlaceholder .= "`n"

    Gui Add, Text, xm Section w%textW%, Commits:
    Gui Add, Edit, xs w%resultW% vCommitsURLs ReadOnly, %resultsPlaceholder%
    Gui Add, Button, xs gCopyCommitsURLs, Copy Commits URLs

    Gui Add, Text, xm Section w%textW%, Diffs:
    Gui Add, Edit, xs w%resultW% vDiffsURLs ReadOnly, %resultsPlaceholder%
    Gui Add, Button, xs gCopyDiffsURLs, Copy Diffs URLs

    Gui Show
}

ParseClipboardURLs(dataType) {
    Local
    Global repoToVarName, freezeUpdates
    if (dataType != 1) ; only text
        return

    ClipWait, 1
    if (ErrorLevel)
        return

    ; parse the clipboard data
    ; RegExMatch(Haystack, NeedleRegEx [, UnquotedOutputVar = "", StartingPos = 1])
    clip := Clipboard
    nextPos := 1
    freezeUpdates := true
    While (nextPos < StrLen(clip) && RegExMatch(clip, "mO)(Revision: (?P<Revision>\w+)$\s*Repository: (?P<Repository>[^\r\n]+))", out, nextPos)) {
        nextPos := out.Pos() + out.Len()

        destVar := repoToVarName[out.Repository]
        If (!destVar) {
            MsgBox % "Unknown repository: " out.Repository
            Continue
        }

        ; GuiControl, SubCommand, ControlID [, Value]
        GuiControl, , % destVar, % out.Revision
    }
    freezeUpdates := false
    UpdateOutputs()
}

UpdateOutputs(CtrlHwnd := "", GuiEvent := "", EventInfo := "", ErrLevel:="") {
    Local

    Global freezeUpdates, repoToVarName, PrevReleaseTag
        , DockerCommit, ModulesCommit, FreeswitchCommit, OpenSIPSCommit
        , CommitsURLs, DiffsURLs
    If (freezeUpdates) {
        Return
    }

    Gui Submit, NoHide

    CommitsURLs := ""
    DiffsURLs := ""

    For repo, destVar in repoToVarName {
        commitHash := %destVar%
        If (!commitHash)
            continue ; skip empty commit hashes
        repo := RegExReplace(repo, "\.git?$", "") ; remove .git suffix
        CommitsURLs .= repo "/commits/" commitHash "`n"
        If (PrevReleaseTag && PrevReleaseTag != "asr-release-")
            DiffsURLs .= repo "/branches/compare/" commitHash "%0D" PrevReleaseTag "`n"
    }

    GuiControl,, CommitsURLs, %CommitsURLs%
    GuiControl,, DiffsURLs, %DiffsURLs%
    ; MsgBox freezeUpdates: %freezeUpdates%`nCommitsURLs: %CommitsURLs%
}

CopyCommitsURLs(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    Global CommitsURLs
    
    Clipboard := CommitsURLs
}

CopyDiffsURLs(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="") {
    Global DiffsURLs
    
    Clipboard := DiffsURLs
}

GuiClose:
GuiEscape:
ExitApp
