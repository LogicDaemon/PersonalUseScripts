;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
#Persistent
#SingleInstance force
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

ClipWait 0
If (ErrorLevel)
    ExitApp
out := CutTrelloURLs(Clipboard)
If (!ErrorLevel) {
    currentRegex := args[1]
    helpTooltip = h → remove "https://"`nt → remove "trello.com"`nf → expand to FreshDesk tag ;x → expand to title`n
    
    ;Hotkey vk41, FindTrelloCard; vk41=a
    Hotkey vk46, ComputerURLsToTags ; vk46=f
    Hotkey vk48, RemoveHttpsPrefix ; vk48=h
    Hotkey vk54, RemoveTrellocomPrefix ; vk54=t
    ;Hotkey x, ExpandToTitle
    ; [v1.1.20+]: If not a valid label name, this parameter can be the name of a function, or a single variable reference containing a function object. For example, Hotkey %FuncObj%, On or Hotkey % FuncObj, On. Other expressions which return objects are currently unsupported. When the hotkey executes, the function is called without parameters. Hotkeys can also be defined as functions without the Hotkey command.
    ; but it seems "bind" always uses var value instead of passing ByRef
    
    ClipTooltipAndTimeout(out, helpTooltip)
    Loop
        Input actn, L1 B I V *, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause},h,t,{vk48},{vk54} ; T2
    Until ErrorLevel!="Match"
    QuitWithClip(out)
}
ExitApp

RemoveHttpsPrefix:
RemoveTrellocomPrefix:
    prefix := {RemoveHttpsPrefix: ["https://"]
             , RemoveTrellocomPrefix: ["https://trello.com", "trello.com"]}[A_ThisLabel]
    For type, currentRegex in GetTrelloURLRegex()
        out := RegexProcess(out, currentRegex, Func("RemovePrefix").Bind(prefix))
    If (A_ThisLabel == "RemoveTrellocomPrefix")
        QuitWithClip(out)
    ClipTooltipAndTimeout(out)
return

ComputerURLsToTags:
    Critical
    out := RegexProcess(out, GetTrelloURLRegex("card"), Func("CardToFreshdeskTag"))
    QuitWithClip(out)
    Critical Off
return

CardToFreshdeskTag(ByRef cardURL) {
    static cards
    ;FindTrelloCard(ByRef SearchParams, ByRef cards, ByRef nMatches := 0, ByRef RegexSearches := "") {
    ; SearchParams = { Hostname: {(Hostname): "Hostname"
    ;			       , (Hostname): "NV Hostname", (Hostname): "ComputerName", (Hostname): "Hostname name", …}
    ;   	     , Hostname: (Hostname) ; alt to previous
    ;		     , TVID: (TVID)
    ;		     , URL: (ShortURL or just ID from it)
    ;		     , MACAddress: {(MAC): "Adapter name", (MAC): "Adapter name", …}
    ;		     , MACAddress: (MAC) ; alt to previous
    ;		     , id: (CardID)
    ;		     , descSubstr: {substring: "name", substring2: "name", …}
    ;		     , descSubstr: (substring of card.desc) ; alt to previous
    ;		     , any_other_field_name: (value)
    ;		     , any_other_field_name: {value: "match description", value: "match description", …}, …}
    ; key is query, and value is name because there can be duplicate names (and duplicate values), but no duplicate keys (neither reason for duplicate queries)
    If (!IsObject(cards))
        cards := LoadComputerAccountingCards()
    cardsFound := FindTrelloCard({URL: CutTrelloCardURL(cardURL, 1)}, cards)
    For i in cardsFound
        card := cards[i], break
    If (IsObject(card)) {
        return ExtractHostnameFromCardName(card.name) A_Space CutTrelloCardURL(cardURL, 2)
    } Else
        return cardURL
}

ClipTooltipAndTimeout(ByRef out, ByRef helpTooltip := "") {
    static lastTooltip, QuitWithOut
    If (IsObject(QuitWithOut))
        SetTimer % QuitWithOut, Off
    If (helpTooltip)
        lastTooltip := helpTooltip
    ToolTip %lastTooltip%`n`n%out%
    QuitWithOut := Func("QuitWithClip").Bind(out)
    SetTimer % QuitWithOut, -2000
}

QuitWithClip(newClip := "") {
    If (newClip)
        Clipboard := newClip
    ToolTip
    ExitApp
}

RemovePrefix(prefixList, ByRef str) {
    If (!IsObject(prefixList))
        prefixList := [prefixList]
    For i, prefix in prefixList {
        prefixLen := StrLen(prefix)
        If (SubStr(str, 1, prefixLen) = prefix)
            return SubStr(str, prefixLen+1)
    }
    return str
}

#include <CutTrelloURLs>
#include <RegexProcess>
#include <FindTrelloCard>
#include <LoadComputerAccountingCards>
