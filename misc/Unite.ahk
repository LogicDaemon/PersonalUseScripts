;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LocalAppData

cb := Clipboard
If (cb)
    startMeeting := RegExMatch(cb, "O)(?:(?:https?|anymeeting)://)?((?:www|meeting)\.)?(?P<meeting_linkpart>anymeeting(?:-.+)?\.com/(?P<meeting_id>[^\s]+))", m)

Run "%LocalAppData%\Programs\scoop\apps\python\current\pythonw.exe" "%LocalAppData%\Scripts\py\update_random_background.py", %A_Temp%, Min

; If there is a meeting link in the clipboard,
;   If Chrome is running, open the link in Chrome.
;   Otherwise, if Unite is running, open in Unite.
;   If neither, open in Chrome.
; Otherwise, start Unite.
; If (!startMeeting) {
    useUnite := True
; } Else {
;     Process Exist, chrome.exe
;     If (!ErrorLevel) {
;         Process Exist, Intermedia Unite.exe
;         If (ErrorLevel) {
;             useUnite := True
;         } Else {
;             useUnite := False
;         }
;     }
; }

If (useUnite) {
    ;(3) Welcome | AnyMeeting
    ActivateOrRun("ahk_class Chrome_WidgetWin_1 ahk_exe Intermedia Unite.exe",, """" LocalAppData "\Programs\Intermedia Unite\Intermedia Unite.exe"" --update-channel fkdblnfdlkbncx", LocalAppData "\Programs\Intermedia Unite")
    ; https://anymeeting.com/vpetrenko
    If (startMeeting)
        Run % "anymeeting://" m.meeting_linkpart
    ExitApp
}

meetingURL := ""
If (startMeeting) {
    gitcfg := ReadGitConfig({"user": {"name": A_UserName, "email":  name "@intermedia.com"}})
    meetingURL := "https://meeting.anymeeting.com/" m.meeting_id 
                . "?name=" UriEncode(gitcfg.user.name) 
                . "&email=" UriEncode(gitcfg.user.email) 
                . "&lang=en-US"
}
MsgBox % meetingURL
Run "%A_AhkPath%" "%A_ScriptDir%\Chrome.ahk" "%meetingURL%"
ExitApp

ReadGitConfig(readSectionsKeys) {
    local
    EnvGet UserProfile, UserProfile

    out := {}
    foundSection := ""
    Loop, Read, % UserProfile "\.gitconfig"
    {
        If (RegexMatch(A_LoopReadLine, "^\s*\[(?P<ection>.*)\]\s*$", s)) {
            If readSectionsKeys.HasKey(section) {
                foundSection := readSectionsKeys[section]
                out[section] := outSection := {}
            } Else {
                foundSection := ""
            }
            Continue
        }
        If (!foundSection)
            Continue

        lineData := StrSplit(A_LoopReadLine, "=")
        key := Trim(lineData[1])
        If (!foundSection.HasKey(key))
            Continue
        value := Trim(lineData[2])
        outSection[key] := value
    }
    Return out
}

#include <URIEncodeDecode>
