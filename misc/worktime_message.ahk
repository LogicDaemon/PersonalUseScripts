;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

; A_Now is YYYYMMDDHHMMSS
hh := SubStr(A_Now, 9, 2)
hh_end := hh+9
mm := SubStr(A_Now, 11, 2)

; round minutes to 15
mm := Round(mm/15-0.5)*15
minutes := {00:"", 15:"¹⁵", 30:"³⁰", 45:"⁴⁵"}[mm]

tz := GetTimezone()

worktime = %hh%%minutes%-%hh_end%%minutes% %tz%
clipBak := ClipboardAll
Clipboard := worktime
Sleep 200
If (Clipboard != worktime)
    ClipWait 1
If (Clipboard == worktime) {
    Send +{Insert}
    Sleep 200
} Else
    showError := Clipboard

KeyWait LWin
KeyWait RWin
KeyWait Alt
Clipboard := clipBak

If (showError)
    MsgBox, 0x10, Error, Clipboard content mismatch. Expected: %worktime%, got: "%showError%"

GetTimezone()
{
    tzRename := {"Russian Standard Time": "MSK"}
    RegRead tz, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation, TimeZoneKeyName
    If (tzRename.HasKey(tz))
        return tzRename[tz]
    RegRead disp, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\%tz%, Display
    return disp
}
