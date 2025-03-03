;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv
#NoTrayIcon
#SingleInstance force
#HotkeyModifierTimeout 0 ; it always times out (modifier keys are never pushed back down).

Process Priority,, High

ListLines Off
;SendMode InputThenPlay ; keyhook in installed either way because of some hotkeys
SetKeyDelay -1,-1
;SetBatchLines -1
SetFormat FloatFast, 0.3
SetFormat IntegerFast, Dec

SetTitleMatchMode RegEx

;Defining some constants
WM_MENUSELECT:=0x011F

WindowSplitSize:=[1.2, 1.5, 1920/1024, 2, 2.5]
magnitudeSeq:=WindowSplitSize.MinIndex()

SplitPath A_AhkPath,, AhkExeDir
EnvGet ProgramFilesx86, ProgramFiles(x86)
If Not ProgramFilesx86
    ProgramFilesx86 := ProgramFiles
EnvGet LocalAppData, LOCALAPPDATA
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot
laPrograms := LocalAppData "\Programs"
hotkeys_custom_ahk := FirstExisting( A_ScriptDir "\Hotkeys_Custom." A_USERNAME "@" A_COMPUTERNAME ".ahk"
                                   , A_ScriptDir "\Hotkeys_Custom." A_COMPUTERNAME ".ahk"
                                   , A_ScriptDir "\Hotkeys_Custom." A_USERNAME ".ahk"
                                   , A_ScriptDir "\Hotkeys_Custom.ahk" ) ; same order as includes

GroupAdd WindowsActionCenter, Action center ahk_class Windows.UI.Core.CoreWindow ahk_exe ShellExperienceHost.exe

GroupAdd ExcludedFromAutoReplace, ahk_class ^SALFRAME
;GroupAdd ExcludedFromAutoReplace, ahk_class ^OperaWindowClass
GroupAdd ExcludedFromAutoReplace, ahk_class ^{E7076D1C-A7BF-4f39-B771-BCBE88F2A2A8}
GroupAdd ExcludedFromAutoReplace, ahk_class ^TMsgWindow
GroupAdd ExcludedFromAutoReplace, ahk_class ^ConsoleWindowClass
;GroupAdd ExcludedFromAutoReplace, ahk_class ^Notepad2, ANSI
GroupAdd ExcludedFromAutoReplace, \.(bat|cmd|py|go|js|yaml|yml) ahk_class ^Notepad2
;GroupAdd ExcludedFromAutoReplace, \.ahk ahk_class ^Notepad2
GroupAdd ExcludedFromAutoReplace, \.(bat|cmd|py|go|js|yaml|yml)\b.* - Visual Studio Code ahk_exe \bCode\.exe\b

GroupAdd NonStandardLayoutSwitching, ahk_exe \iexplore\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \boutlook\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bOUTLOOK\.EXE\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bcmd\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bconhost\.exe\b
GroupAdd NonStandardLayoutSwitching, ahk_exe \bWINWORD\.EXE\b
GroupAdd NonStandardLayoutSwitching, ahk_class ^OpusApp

GroupAdd NoLayoutSwitching, ahk_exe CDViewer\.exe

;GroupAdd OverrideMultimediaHotkeys, ahk_exe ts3client_win64.exe

calcexe := FirstExisting(laPrograms "\speedcrunch-0.12-win32\speedcrunch.exe"
                       , laPrograms "\calculators\preccalc-32bit\preccalc.exe"
                       , SystemRoot "\System32\calc.exe" )
For i, exe64suffix in (A_Is64bitOS ? ["64", ""] : [""]) {
    If (!totalcmdexe)
        totalcmdexe := FirstExisting(laPrograms "\Total Commander\TOTALCMD" exe64suffix ".EXE"
                                   , ProgramFiles . "\Total Commander\TOTALCMD" exe64suffix ".EXE"
                                   , ProgramFilesx86 . "\Total Commander\TOTALCMD" exe64suffix ".EXE")
    If (!procexpexe)
        procexpexe := FirstExisting(laPrograms "\SysUtils\SysInternals\procexp" exe64suffix ".exe"
                                  , laPrograms "\SysInternals\procexp" exe64suffix ".exe"
                                  , SystemDrive "\SysUtils\SysInternals\procexp" exe64suffix ".exe")
}
vscode := A_ScriptDir "\vscode-any.ahk"
notepad2exe := FirstExisting(laPrograms "\Total Commander\notepad2.exe"
                           , totalcmdexe "\..\notepad2.exe"
                           , ProgramFiles "\notepad2\notepad2.exe"
                           , ProgramFilesx86 "\notepad2\notepad2.exe"
                           , ProgramFilesx86 "\Notepad++\notepad++.exe"
                           , LocalAppData "\Programs\VS Code\Code.exe"
                           , SystemRoot "\System32\notepad.exe")

AU3_Spy := FirstExisting( AhkExeDir "\AU3_Spy.exe"
                                   , AhkExeDir "\AU3_Spy.exe"
                                   , laPrograms "\AutoHotkey\AU3_Spy.exe"
                                   , AhkExeDir "\WindowSpy.ahk"
                                   , laPrograms "\AutoHotkey\WindowSpy.ahk" )

keepassahk := FirstExisting(A_ScriptDir "\KeePass_" A_UserName ".ahk", A_ScriptDir "\KeePass.ahk")

FileAppend Found executables:`ncalc: %calcexe%`nnotepad2: %notepad2exe%`ntc: %totalcmdexe%`nprocexp: %procexpexe%`nkeepassahk: %keepassahk%, *

layouts := GetLayoutList()


FillDelayedRunGroups()

;save a bit on memory if Windows 5 or newer - MilesAhead
DllCall("psapi.dll\EmptyWorkingSet", "Int", -1, "Int")

#include *i %A_ScriptDir%\Hotkeys_Custom.%A_USERNAME%@%A_COMPUTERNAME%.ahk
#include *i %A_ScriptDir%\Hotkeys_Custom.%A_COMPUTERNAME%.ahk
#include *i %A_ScriptDir%\Hotkeys_Custom.%A_USERNAME%.ahk
#include *i %A_ScriptDir%\Hotkeys_Custom.ahk
return

;#IfWinExist ahk_group OverrideMultimediaHotkeys
Launch_Media::F13
Launch_App1::F14
Launch_App2::F15
;#IfWinExist

#IfWinNotActive ahk_group ExcludedFromAutoReplace
    #Hotstring * ? C Z
    ;* (asterisk): An ending character (e.g. space, period, or enter) is not required to trigger the hotstring
    ;? (question mark): The hotstring will be triggered even when it is inside another word
    ;B0 (B followed by a zero): Automatic backspacing is not done to erase the abbreviation you type
    ;C: Case sensitive
    ;C1: Do not conform to typed case. Hotstrings become case insensitive and non-conforming to the case of the characters you actually type
    ;Kn: Key-delay; k10 to have a 10ms delay and k-1 to have no delay
    ;O: Omit the ending character of auto-replace hotstrings when the replacement is produced
    ;R: Send the replacement text raw
    ;SI or SP or SE [v1.0.43+]: Sets the method by which auto-replace hotstrings send their keystrokes
    ;Z: This rarely-used option resets the hotstring recognizer after each triggering of the hotstring
    
    ;typography
    ;:?:"<::«
    ;::ЭБ::«
    ;:?:">::»
    ;::ЭЮ::»
    #Hotstring * ?0 C
    ;arrows
    ::<-- ::← `
    ::--> ::→ `
    ::^|| ::↑ `
    ::v|| ::↓ `
    ;dashes
    ::--- ::— `
    ;-- is after arrows which also use --
    ::-- ::– `
    ::... ::…`
    ;double arrows
    ::[<=>] ::⇔ `
    ::[<=] ::⇐ `
    ::[=>] ::⇒ `
    ;math
    ::[>=] ::≥ `
    ::[<=] ::≤ `
    ::[!=] ::≠ `
    ::[==] ::≡ `
    ::[~=] ::≅ `
    ::[~~] ::≈ `
    ::[+-] ::± `
    ;physics
    ::[ps] ::㎰ ` ; U+33B0 e3 8e b0 	SQUARE PS
    ::[ns] ::㎱ ` ; U+33B1 e3 8e b1 	SQUARE NS
    ::[us] ::㎲ ` ; U+33B2 e3 8e b2 	SQUARE MU L
    ::[ms] ::㎳ ` ; U+33B3 e3 8e b3 	SQUARE MS
    ;other
    ::[link] ::🔗 ; U+1F517 f0 9f 94 97  Link Symbol
    ::[ ] ::☐ ` ; U+2610 e2 98 90 	BALLOT BOX
    ::[v] ::☑ ` ; U+2611 e2 98 91 	BALLOT BOX WITH CHECK
    ::[X] ::☒ ` ; U+2612 e2 98 92 	BALLOT BOX WITH X
    ::_x_ ::✗ ` ; U+2717 e2 9c 97 	BALLOT X
    ::*X* ::✘ ` ; U+2718 e2 9c 98 	HEAVY BALLOT X
    ::[x] ::⮽ ` ; U+2BBD e2 ae bd 	BALLOT BOX WITH LIGHT X
    ::_x_ ::🗴 ` ; U+1F5F4 f0 9f 97 b4 	BALLOT SCRIPT X
    ::[_x_] ::🗵 ` ; U+1F5F5 f0 9f 97 b5 	BALLOT BOX WITH SCRIPT X
    ::_*x*_ ::🗶 ` ; U+1F5F6 f0 9f 97 b6 	BALLOT BOLD SCRIPT X
    ::[_*x*_] ::🗷 ` ; U+1F5F7 f0 9f 97 b7 	BALLOT BOX WITH BOLD SCRIPT X
    ::[V] ::🗹 ` ; U+1F5F9 f0 9f 97 b9 	BALLOT BOX WITH BOLD CHECK
    ::[y] ::🗸 ` ; U+1F5F8 f0 9f 97 b8 	BALLOT BOX WITH CHECK
    ::[b*] ::★ ` ; U+2605 e2 98 85 	BLACK STAR
    ::[w*] ::☆ ` ; U+2606 e2 98 86 	WHITE STAR

    ::[^1] ::¹ ; U+00B9 c2 b9 	SUPERSCRIPT ONE
    ::[^2] ::² ; U+00B2 c2 b2 	SUPERSCRIPT TWO
    ::[^3] ::³ ; U+00B3 c2 b3 	SUPERSCRIPT THREE
    ::[^0] ::⁰ ; U+2070 E2 81 B0  SUPERSCRIPT ZERO
    ::[^i] ::ⁱ ; U+2071 E2 81 B1  SUPERSCRIPT LATIN SMALL LETTER I
    ::[^4] ::⁴ ; U+2074 E2 81 B4  SUPERSCRIPT FOUR
    ::[^5] ::⁵ ; U+2075 E2 81 B5  SUPERSCRIPT FIVE
    ::[^6] ::⁶ ; U+2076 E2 81 B6  SUPERSCRIPT SIX
    ::[^7] ::⁷ ; U+2077 E2 81 B7  SUPERSCRIPT SEVEN
    ::[^8] ::⁸ ; U+2078 E2 81 B8  SUPERSCRIPT EIGHT
    ::[^9] ::⁹ ; U+2079 E2 81 B9  SUPERSCRIPT NINE
    ::[^+] ::⁺ ; U+207A E2 81 BA  SUPERSCRIPT PLUS SIGN
    ::[^-] ::⁻ ; U+207B E2 81 BB  SUPERSCRIPT MINUS
    ::[^=] ::⁼ ; U+207C E2 81 BC  SUPERSCRIPT EQUALS SIGN
    ::[^(] ::⁽ ; U+207D E2 81 BD  SUPERSCRIPT LEFT PARENTHESIS
    ::[^)] ::⁾ ; U+207E E2 81 BE  SUPERSCRIPT RIGHT PARENTHESIS
    ::[^n] ::ⁿ ; U+207F E2 81 BF  SUPERSCRIPT LATIN SMALL LETTER N

    ::[s0] ::₀ ; U+2080 E2 82 80  SUBSCRIPT ZERO
    ::[s1] ::₁ ; U+2081 E2 82 81  SUBSCRIPT ONE
    ::[s2] ::₂ ; U+2082 E2 82 82  SUBSCRIPT TWO
    ::[s3] ::₃ ; U+2083 E2 82 83  SUBSCRIPT THREE
    ::[s4] ::₄ ; U+2084 E2 82 84  SUBSCRIPT FOUR
    ::[s5] ::₅ ; U+2085 E2 82 85  SUBSCRIPT FIVE
    ::[s6] ::₆ ; U+2086 E2 82 86  SUBSCRIPT SIX
    ::[s7] ::₇ ; U+2087 E2 82 87  SUBSCRIPT SEVEN
    ::[s8] ::₈ ; U+2088 E2 82 88  SUBSCRIPT EIGHT
    ::[s9] ::₉ ; U+2089 E2 82 89  SUBSCRIPT NINE
    ::[s+] ::₊ ; U+208A E2 82 8A  SUBSCRIPT PLUS SIGN
    ::[s-] ::₋ ; U+208B E2 82 8B  SUBSCRIPT MINUS
    ::[s=] ::₌ ; U+208C E2 82 8C  SUBSCRIPT EQUALS SIGN
    ::[s(] ::₍ ; U+208D E2 82 8D  SUBSCRIPT LEFT PARENTHESIS
    ::[s)] ::₎ ; U+208E E2 82 8E  SUBSCRIPT RIGHT PARENTHESIS

    ::[si] ::ᵢ ; U+1D62 E1 B5 A2 	LATIN SUBSCRIPT SMALL LETTER I
    ::[sr] ::ᵣ ; U+1D63 E1 B5 A3 	LATIN SUBSCRIPT SMALL LETTER R
    ::[su] ::ᵤ ; U+1D64 E1 B5 A4 	LATIN SUBSCRIPT SMALL LETTER U
    ::[sv] ::ᵥ ; U+1D65 E1 B5 A5 	LATIN SUBSCRIPT SMALL LETTER V
    ::[sb] ::ᵦ ; U+1D66 E1 B5 A6 	LATIN SUBSCRIPT SMALL LETTER B
    ::[sy] ::ᵧ ; U+1D67 E1 B5 A7 	LATIN SUBSCRIPT SMALL LETTER Y

    ::[sA] ::ₐ ; U+2090 E2 82 90  LATIN SUBSCRIPT SMALL LETTER A
    ::[sE] ::ₑ ; U+2091 E2 82 91  LATIN SUBSCRIPT SMALL LETTER E
    ::[sO] ::ₒ ; U+2092 E2 82 92  LATIN SUBSCRIPT SMALL LETTER O
    ::[sX] ::ₓ ; U+2093 E2 82 93  LATIN SUBSCRIPT SMALL LETTER X
    ::[sH] ::ₕ ; U+2095 E2 82 95  LATIN SUBSCRIPT SMALL LETTER H
    ::[sK] ::ₖ ; U+2096 E2 82 96  LATIN SUBSCRIPT SMALL LETTER K
    ::[sL] ::ₗ ; U+2097 E2 82 97  LATIN SUBSCRIPT SMALL LETTER L
    ::[sM] ::ₘ ; U+2098 E2 82 98  LATIN SUBSCRIPT SMALL LETTER M
    ::[sN] ::ₙ ; U+2099 E2 82 99  LATIN SUBSCRIPT SMALL LETTER N
    ::[sP] ::ₚ ; U+209A E2 82 9A  LATIN SUBSCRIPT SMALL LETTER P
    ::[sS] ::ₛ ; U+209B E2 82 9B  LATIN SUBSCRIPT SMALL LETTER S
    ::[sT] ::ₜ ; U+209C E2 82 9C  LATIN SUBSCRIPT SMALL LETTER T
    ::[sJ] ::ⱼ ; U+2C7C E2 B1 BC  LATIN SUBSCRIPT SMALL LETTER J

    ::[0100] ::🕐 ` ; U+1F550 f0 9f 95 90 	CLOCK FACE ONE OCLOCK
    ::[0200] ::🕑 ` ; U+1F551 f0 9f 95 91 	CLOCK FACE TWO OCLOCK
    ::[0300] ::🕒 ` ; U+1F552 f0 9f 95 92 	CLOCK FACE THREE OCLOCK
    ::[0400] ::🕓 ` ; U+1F553 f0 9f 95 93 	CLOCK FACE FOUR OCLOCK
    ::[0500] ::🕔 ` ; U+1F554 f0 9f 95 94 	CLOCK FACE FIVE OCLOCK
    ::[0600] ::🕕 ` ; U+1F555 f0 9f 95 95 	CLOCK FACE SIX OCLOCK
    ::[0700] ::🕖 ` ; U+1F556 f0 9f 95 96 	CLOCK FACE SEVEN OCLOCK
    ::[0800] ::🕗 ` ; U+1F557 f0 9f 95 97 	CLOCK FACE EIGHT OCLOCK
    ::[0900] ::🕘 ` ; U+1F558 f0 9f 95 98 	CLOCK FACE NINE OCLOCK
    ::[1000] ::🕙 ` ; U+1F559 f0 9f 95 99 	CLOCK FACE TEN OCLOCK
    ::[1100] ::🕚 ` ; U+1F55A f0 9f 95 9a 	CLOCK FACE ELEVEN OCLOCK
    ::[1200] ::🕛 ` ; U+1F55B f0 9f 95 bb 	CLOCK FACE TWELVE OCLOCK
    ::(A) ::Ⓐ ` ; U+24B6 e2 92 b6 	CIRCLED LATIN CAPITAL LETTER A
    ::(B) ::Ⓑ ` ; U+24B7 e2 92 b7 	CIRCLED LATIN CAPITAL LETTER B
    ::(C) ::Ⓒ ` ; U+24B8 e2 92 b8 	CIRCLED LATIN CAPITAL LETTER C
    ::(D) ::Ⓓ ` ; U+24B9 e2 92 b9 	CIRCLED LATIN CAPITAL LETTER D
    ::(E) ::Ⓔ ` ; U+24BA e2 92 ba 	CIRCLED LATIN CAPITAL LETTER E
    ::(F) ::Ⓕ ` ; U+24BB e2 92 bb 	CIRCLED LATIN CAPITAL LETTER F
    ::(G) ::Ⓖ ` ; U+24BC e2 92 bc 	CIRCLED LATIN CAPITAL LETTER G
    ::(H) ::Ⓗ ` ; U+24BD e2 92 bd 	CIRCLED LATIN CAPITAL LETTER H
    ::(I) ::Ⓘ ` ; U+24BE e2 92 be 	CIRCLED LATIN CAPITAL LETTER I
    ::(J) ::Ⓙ ` ; U+24BF e2 92 bf 	CIRCLED LATIN CAPITAL LETTER J
    ::(K) ::Ⓚ ` ; U+24C0 e2 93 80 	CIRCLED LATIN CAPITAL LETTER K
    ::(L) ::Ⓛ ` ; U+24C1 e2 93 81 	CIRCLED LATIN CAPITAL LETTER L
    ::(M) ::Ⓜ ` ; U+24C2 e2 93 82 	CIRCLED LATIN CAPITAL LETTER M
    ::(N) ::Ⓝ ` ; U+24C3 e2 93 83 	CIRCLED LATIN CAPITAL LETTER N
    ::(O) ::Ⓞ ` ; U+24C4 e2 93 84 	CIRCLED LATIN CAPITAL LETTER O
    ::(P) ::Ⓟ ` ; U+24C5 e2 93 85 	CIRCLED LATIN CAPITAL LETTER P
    ::(Q) ::Ⓠ ` ; U+24C6 e2 93 86 	CIRCLED LATIN CAPITAL LETTER Q
    ::(R) ::Ⓡ ` ; U+24C7 e2 93 87 	CIRCLED LATIN CAPITAL LETTER R
    ::(S) ::Ⓢ ` ; U+24C8 e2 93 88 	CIRCLED LATIN CAPITAL LETTER S
    ::(T) ::Ⓣ ` ; U+24C9 e2 93 89 	CIRCLED LATIN CAPITAL LETTER T
    ::(U) ::Ⓤ ` ; U+24CA e2 93 8a 	CIRCLED LATIN CAPITAL LETTER U
    ::(V) ::Ⓥ ` ; U+24CB e2 93 8b 	CIRCLED LATIN CAPITAL LETTER V
    ::(W) ::Ⓦ ` ; U+24CC e2 93 8c 	CIRCLED LATIN CAPITAL LETTER W
    ::(X) ::Ⓧ ` ; U+24CD e2 93 8d 	CIRCLED LATIN CAPITAL LETTER X
    ::(Y) ::Ⓨ ` ; U+24CE e2 93 8e 	CIRCLED LATIN CAPITAL LETTER Y
    ::(Z) ::Ⓩ ` ; U+24CF e2 93 8f 	CIRCLED LATIN CAPITAL LETTER Z
    ::(a) ::ⓐ ` ; U+24D0 e2 93 90 	CIRCLED LATIN SMALL LETTER A
    ::(b) ::ⓑ ` ; U+24D1 e2 93 91 	CIRCLED LATIN SMALL LETTER B
    ::(c) ::ⓒ ` ; U+24D2 e2 93 92 	CIRCLED LATIN SMALL LETTER C
    ::(d) ::ⓓ ` ; U+24D3 e2 93 93 	CIRCLED LATIN SMALL LETTER D
    ::(e) ::ⓔ ` ; U+24D4 e2 93 94 	CIRCLED LATIN SMALL LETTER E
    ::(f) ::ⓕ ` ; U+24D5 e2 93 95 	CIRCLED LATIN SMALL LETTER F
    ::(g) ::ⓖ ` ; U+24D6 e2 93 96 	CIRCLED LATIN SMALL LETTER G
    ::(h) ::ⓗ ` ; U+24D7 e2 93 97 	CIRCLED LATIN SMALL LETTER H
    ::(i) ::ⓘ ` ; U+24D8 e2 93 98 	CIRCLED LATIN SMALL LETTER I
    ::(j) ::ⓙ ` ; U+24D9 e2 93 99 	CIRCLED LATIN SMALL LETTER J
    ::(k) ::ⓚ ` ; U+24DA e2 93 9a 	CIRCLED LATIN SMALL LETTER K
    ::(l) ::ⓛ ` ; U+24DB e2 93 9b 	CIRCLED LATIN SMALL LETTER L
    ::(m) ::ⓜ ` ; U+24DC e2 93 9c 	CIRCLED LATIN SMALL LETTER M
    ::(n) ::ⓝ ` ; U+24DD e2 93 9d 	CIRCLED LATIN SMALL LETTER N
    ::(o) ::ⓞ ` ; U+24DE e2 93 9e 	CIRCLED LATIN SMALL LETTER O
    ::(p) ::ⓟ ` ; U+24DF e2 93 9f 	CIRCLED LATIN SMALL LETTER P
    ::(q) ::ⓠ ` ; U+24E0 e2 93 a0 	CIRCLED LATIN SMALL LETTER Q
    ::(r) ::ⓡ ` ; U+24E1 e2 93 a1 	CIRCLED LATIN SMALL LETTER R
    ::(s) ::ⓢ ` ; U+24E2 e2 93 a2 	CIRCLED LATIN SMALL LETTER S
    ::(t) ::ⓣ ` ; U+24E3 e2 93 a3 	CIRCLED LATIN SMALL LETTER T
    ::(u) ::ⓤ ` ; U+24E4 e2 93 a4 	CIRCLED LATIN SMALL LETTER U
    ::(v) ::ⓥ ` ; U+24E5 e2 93 a5 	CIRCLED LATIN SMALL LETTER V
    ::(w) ::ⓦ ` ; U+24E6 e2 93 a6 	CIRCLED LATIN SMALL LETTER W
    ::(x) ::ⓧ ` ; U+24E7 e2 93 a7 	CIRCLED LATIN SMALL LETTER X
    ::(y) ::ⓨ ` ; U+24E8 e2 93 a8 	CIRCLED LATIN SMALL LETTER Y
    ::(z) ::ⓩ ` ; U+24E9 e2 93 a9 	CIRCLED LATIN SMALL LETTER Z
    ::(0) ::⓪ ` ; U+24EA e2 93 aa 	CIRCLED DIGIT ZERO
    ::(1) ::① ` ; U+2460 e2 91 a0 	CIRCLED DIGIT ONE
    ::(2) ::② ` ; U+2461 e2 91 a1 	CIRCLED DIGIT TWO
    ::(3) ::③ ` ; U+2462 e2 91 a2 	CIRCLED DIGIT THREE
    ::(4) ::④ ` ; U+2463 e2 91 a3 	CIRCLED DIGIT FOUR
    ::(5) ::⑤ ` ; U+2464 e2 91 a4 	CIRCLED DIGIT FIVE
    ::(6) ::⑥ ` ; U+2465 e2 91 a5 	CIRCLED DIGIT SIX
    ::(7) ::⑦ ` ; U+2466 e2 91 a6 	CIRCLED DIGIT SEVEN
    ::(8) ::⑧ ` ; U+2467 e2 91 a7 	CIRCLED DIGIT EIGHT
    ::(9) ::⑨ ` ; U+2468 e2 91 a8 	CIRCLED DIGIT NINE
    ::(10) ::⑩ ` ; U+2469 e2 91 a9 	CIRCLED NUMBER TEN
    ::(11) ::⑪ ` ; U+246a e2 91 aa 	CIRCLED NUMBER ELEVEN
    ::(12) ::⑫ ` ; U+246b e2 91 ab 	CIRCLED NUMBER TWELVE
    ::(13) ::⑬ ` ; U+246c e2 91 ac 	CIRCLED NUMBER THIRTEEN
    ::(14) ::⑭ ` ; U+246d e2 91 ad 	CIRCLED NUMBER FOURTEEN
    ::(15) ::⑮ ` ; U+246e e2 91 ae 	CIRCLED NUMBER FIFTEEN
    ::(16) ::⑯ ` ; U+246f e2 91 af 	CIRCLED NUMBER SIXTEEN
    ::(17) ::⑰ ` ; U+2470 e2 91 b0 	CIRCLED NUMBER SEVENTEEN
    ::(18) ::⑱ ` ; U+2471 e2 91 b1 	CIRCLED NUMBER EIGHTEEN
    ::(19) ::⑲ ` ; U+2472 e2 91 b2 	CIRCLED NUMBER NINETEEN
    ::(20) ::⑳ ` ; U+2473 e2 91 b3 	CIRCLED NUMBER TWENTY
    ::(21) ::㉑ ` ; U+3251 e3 89 91 	CIRCLED NUMBER TWENTY ONE
    ::(22) ::㉒ ` ; U+3252 e3 89 92 	CIRCLED NUMBER TWENTY TWO
    ::(23) ::㉓ ` ; U+3253 e3 89 93 	CIRCLED NUMBER TWENTY THREE
    ::(24) ::㉔ ` ; U+3254 e3 89 94 	CIRCLED NUMBER TWENTY FOUR
    ::(25) ::㉕ ` ; U+3255 e3 89 95 	CIRCLED NUMBER TWENTY FIVE
    ::(26) ::㉖ ` ; U+3256 e3 89 96 	CIRCLED NUMBER TWENTY SIX
    ::(27) ::㉗ ` ; U+3257 e3 89 97 	CIRCLED NUMBER TWENTY SEVEN
    ::(28) ::㉘ ` ; U+3258 e3 89 98 	CIRCLED NUMBER TWENTY EIGHT
    ::(29) ::㉙ ` ; U+3259 e3 89 99 	CIRCLED NUMBER TWENTY NINE
    ::(30) ::㉚ ` ; U+325a e3 89 9a 	CIRCLED NUMBER THIRTY
    ::(31) ::㉛ ` ; U+325b e3 89 9b 	CIRCLED NUMBER THIRTY ONE
    ::(32) ::㉜ ` ; U+325c e3 89 9c 	CIRCLED NUMBER THIRTY TWO
    ::(33) ::㉝ ` ; U+325d e3 89 9d 	CIRCLED NUMBER THIRTY THREE
    ::(34) ::㉞ ` ; U+325e e3 89 9e 	CIRCLED NUMBER THIRTY FOUR
    ::(35) ::㉟ ` ; U+325f e3 89 9f 	CIRCLED NUMBER THIRTY FIVE
    ::(36) ::㊱ ` ; U+32b1 e3 8a b1 	CIRCLED NUMBER THIRTY SIX
    ::(37) ::㊲ ` ; U+32b2 e3 8a b2 	CIRCLED NUMBER THIRTY SEVEN
    ::(38) ::㊳ ` ; U+32b3 e3 8a b3 	CIRCLED NUMBER THIRTY EIGHT
    ::(39) ::㊴ ` ; U+32b4 e3 8a b4 	CIRCLED NUMBER THIRTY NINE
    ::(40) ::㊵ ` ; U+32b5 e3 8a b5 	CIRCLED NUMBER FORTY
    ::(41) ::㊶ ` ; U+32b6 e3 8a b6 	CIRCLED NUMBER FORTY ONE
    ::(42) ::㊷ ` ; U+32b7 e3 8a b7 	CIRCLED NUMBER FORTY TWO
    ::(43) ::㊸ ` ; U+32b8 e3 8a b8 	CIRCLED NUMBER FORTY THREE
    ::(44) ::㊹ ` ; U+32b9 e3 8a b9 	CIRCLED NUMBER FORTY FOUR
    ::(45) ::㊺ ` ; U+32ba e3 8a ba 	CIRCLED NUMBER FORTY FIVE
    ::(46) ::㊻ ` ; U+32bb e3 8a bb 	CIRCLED NUMBER FORTY SIX
    ::(47) ::㊼ ` ; U+32bc e3 8a bc 	CIRCLED NUMBER FORTY SEVEN
    ::(48) ::㊽ ` ; U+32bd e3 8a bd 	CIRCLED NUMBER FORTY EIGHT
    ::(49) ::㊾ ` ; U+32be e3 8a be 	CIRCLED NUMBER FORTY NINE
    ::(50) ::㊿ ` ; U+32bf e3 8a bf 	CIRCLED NUMBER FIFTY
    ::[10] ::㉈ ` ; U+3248 e3 89 88 	circled number ten on black square
    ::[20] ::㉉ ` ; U+3249 e3 89 89 	circled number twenty on black square
    ::[30] ::㉊ ` ; U+324A e3 89 8a 	circled number thirty on black square
    ::[40] ::㉋ ` ; U+324B e3 89 8b 	circled number forty on black square
    ::[50] ::㉌ ` ; U+324C e3 89 8c 	circled number fifty on black square
    ::[60] ::㉍ ` ; U+324D e3 89 8d 	circled number sixty on black square
    ::[70] ::㉎ ` ; U+324E e3 89 8e 	circled number seventy on black square
    ::[80] ::㉏ ` ; U+324F e3 89 8f 	circled number eighty on black square
    

    #Hotstring *0 ?0 C0 Z0
#IfWinActive

#,::                                                          ;Win+< #<
    clipBak := ClipboardAll
    Clipboard=
    SendEvent +{Delete}
    ClipWait 0
    SendRaw «»
    SendEvent {Left}+{Insert}
    Sleep 50
    Clipboard := clipBak
    clipBak=
return
#+/::               Send ¿                                    ;Win+Shift+/ #+/
#^,::               Send «                                    ;Win+Ctrl+<  #^<
#^.::               Send »                                    ;Win+Ctrl+>  #^>
#+,::               Send ≤                                    ;Win+Shift+< #+<
#+.::               Send ≥                                    ;Win+Shift+> #+>
#!,::               Send ←                                    ;Win+Alt+<   #!<
#!.::               Send →                                    ;Win+Alt+>   #!>
#+VK44::            Send %A_YYYY%-%A_MM%-%A_DD%               ;vk44=d      #+d
#+VK54::            Send %A_Hour%%A_Min%                      ;vk54=t      #+t
#NumpadSub::        Send – ; en dash
#+NumpadSub::       Send — ; em dash
#NumPadMult::       Send ×
#+NumPadMult::      Send ⋆
#!NumPadMult::      Send ☆
#!+NumPadMult::     Send ★
#!Insert::          SendRaw %Clipboard%

#^!+VK5A::          GoTo lReload                                                    ;vk5a=z #^!+z
#^VK43::            Run "%A_AhkPath%" "%A_ScriptDir%\ClipboardMonitor.ahk",, Min    ;vk43=c #^c

#^F1::              Run % "*RunAs " comspec " /K CD /D ""%TEMP%"""
#Enter::            GoTo lMaximizeWindow
#+Enter::           GoTo lToggleWindowMonitor

#^!NumPad0::        WinSet AlwaysOnTop, Toggle, A
#^Delete::          WinKill A
#+Down::            PostMessage 0x112, 0xF020,,, A ; 0x112 = WM_SYSCOMMAND, 0xF020 = SC_MINIMIZE, see https://msdn.microsoft.com/ru-ru/library/windows/desktop/ms646360.aspx

#!Numpad1::
#!Numpad2::
#!Numpad3::
#!Numpad4::
#!Numpad6::
#!Numpad7::
#!Numpad8::
#!Numpad9::
    If (WinActive("ahk_group WindowsActionCenter")) {
        MoveActionCenter(SubStr(A_ThisLabel,0))
        return
    }    
    If ( A_TimeSincePriorHotkey < 1000) {
        If (A_PriorHotkey == A_ThisHotkey)
            magnitudeSeq += magnitudeSeq < WindowSplitSize.MaxIndex()
    } else {
        magnitudeSeq := WindowSplitSize.MinIndex()
    }
    Tooltip % "Magnitude #" . magnitudeSeq . " = " . WindowSplitSize[magnitudeSeq]
    SetTimer RemoveToolTip, 1000
    MoveToCornerNum(SubStr(A_ThisLabel,0), WindowSplitSize[magnitudeSeq])
return

FindWindowMonitorIndex(winX, winY, winW, winH) {
    local
    winCenterX := winX + winW/2, winCenterY := winY + winH/2

    Loop {
        SysGet MonDim, Monitor, %A_Index%
        If ( MonDimLeft <= winCenterX && MonDimRight >= winCenterX && MonDimTop <= winCenterY && MonDimBottom >= winCenterY )
            return A_Index
        ; check for partial overlap
        If ( MonDimLeft < winX+winW && MonDimRight > winX && MonDimTop < winY+winH && MonDimBottom > winY )
            partiallyOnMon := A_Index
    } until !(MonDimLeft || MonDimRight || MonDimTop || MonDimBottom)
    If (partiallyOnMon)
        return partiallyOnMon
    return ""
}

Max(a,b) {
    return a > b ? a : b
}

MoveActionCenter(corner := 0) {
    local
    WinGetPos winX, winY, winW, winH, ahk_group WindowsActionCenter
    
    ;curMon := FindWindowMonitorIndex(winX, winY, winW, winH)
    monCentralPoints := []
    Loop {
        SysGet MonDim, Monitor, %A_Index%
        If (!(MonDimLeft || MonDimRight || MonDimTop || MonDimBottom))
            Break
        If ( MonDimLeft <= winX && MonDimRight >= winX && MonDimTop <= winY && MonDimBottom >= winY )
            curMon := A_Index
        monCentralPoints[A_Index] := [MonDimLeft + (MonDimRight - MonDimLeft)/2, MonDimTop + (MonDimBottom - MonDimTop)/2]
        , monCount := A_Index
        , monMaxWidth := Max(monMaxWidth, MonDimRight - MonDimLeft)
        , monMaxHeight := Max(monMaxHeight, MonDimBottom - MonDimTop)
    }

    If (corner) {
        ; Find the best matching monitor
        ;                 1  2  3  4 5 6  7 8 9
        scoreXmult   := [-1, 0, 1,-3,0,3,-1,0,1][corner]
        , scoreYmult := [-1,-3,-1, 0,0,0, 1,3,1][corner]
        , curMonCenter := monCentralPoints[curMon]
        , bestScore := -1
        For i, mon in monCentralPoints {
            curScoreX := scoreXmult * monMaxWidth / (mon[1] - curMonCenter[1])
            , curScoreY := scoreYmult * monMaxHeight / (mon[2] - curMonCenter[2])
            If (curScoreX < 0 || curScoreY < 0)
                Continue
            curScore := curScoreX*curScoreX + curScoreY*curScoreY
            If (curScore > bestScore)
                bestScore := curScore, newMon := i
        }
    } Else { ; just a next monitor
        newMon := curMon < monCount ? curMon + 1 : 1
    }

    SysGet MonWA, MonitorWorkArea, %newMon%
    newW := winW
    newH := MonWAHeight
    newX := MonWARight - newW
    newY := MonWATop
    ;ToolTip % winX "," winY "," winW "," winH " -> " newX "," newY "," newW "," newH
    WinMove,,, newX, newY, newW, newH
}

FillDelayedRunGroups() {
    ;Error:  Parameter #2 must match an existing #If expression.
    ;--->	087: Hotkey,If,("AlternateHotkeys==" altMode)
    ;vk5a=z #z
    ;vk51=q #q
    #If AlternateHotkeys==0x51
    #If
    local altKey, HotkeysRunDelayed, altMode, altFunc, key, args, hotkeyFunc, OutExtension
    ; {key: [File, Arguments, Directory, Operation, Show], ...} ; Show is as in ShellRun or -1 to run as ahk script (w/o ShellRun)
    ;Show = args[5]:
    ;0 Open the application with a hidden window.
    ;1 Open the application with a normal window. If the window is minimized or maximized, the system restores it to its original size and position.
    ;2 Open the application with a minimized window.
    ;3 Open the application with a maximized window.
    ;4 Open the application with its window at its most recent size and position. The active window remains active.
    ;5 Open the application with its window at its current size and position.
    ;7 Open the application with a minimized window. The active window remains active.
    ;10 Open the application with its window in the default state specified by the application.
        , RunDelayedGroups :=   { "":       { "#!VK43":  [calcexe,, ""]                                          ;VK43=c #!c
                                            , "#VK43":   [A_ScriptDir "\Select audio device.ahk"]                ;VK43=c #c
                                            , "SC132":   [A_ScriptDir "\default_browser.ahk"]                    ;SC132=Homepage
                                            , "#VK57":   [A_ScriptDir "\default_browser.ahk"]                    ;vk57=w #w
                                            , "#+VK57":  [A_ScriptDir "\alt_browser.ahk"]                        ;vk57=w #+w
                                            , "+SC132":  [A_ScriptDir "\alt_browser.ahk"]                        ;SC132=Homepage +Homepage
                                            , "^!+Esc":  [procexpexe]                                            ;^!+Esc
                                            ;, "#SC132":  [A_ScriptDir "\ie.cmd",,,,7]                            ;#Homepage
                                            , "#^!VK57": [A_ScriptDir "\WinActivateOrExec.ahk", """" laPrograms "\Tor Browser\Browser\firefox.exe"""] ;#^!w
                                            , "^!SC132": [A_ScriptDir "\WinActivateOrExec.ahk", """" laPrograms "\Tor Browser\Browser\firefox.exe"""] ;^!Homepage
                                            , "#F1":     [comspec, " /K ""CD /D """ A_ScriptDir """ & PUSHD ""%TEMP%"" & ECHO POPD to go to " A_ScriptDir """"] ;/U https://twitter.com/LogicDaemon/status/936259452617060354
                                            ;, "#+F1":    [LocalAppData "\Programs\bin\mintty.exe", "wsl --cd ~"]
                                            , "#+F1":    [LocalAppData "\Microsoft\WindowsApps\Microsoft.WindowsTerminal_8wekyb3d8bbwe\wt.exe", "nt -p Debian"]
                                            , "#VK45":   [A_ScriptDir "\WinActivateOrExec.ahk", """" totalcmdexe """",,""] ;vk45=e #e
                                            , "#+VK45":  [totalcmdexe,,,,-1]                                     ;vk45=e #+e
                                            , "#!VK45":  ["shell:MyComputerFolder"]                              ;vk45=e #!e
                                            ;, "#^VK45":  [A_ScriptDir "\RemoveDrive.ahk"]                       ;vk45=e #^e
                                            , "#^VK45":  [A_ScriptDir "\PassPhrase\email.ahk"]                   ;vk45=e #^e
                                            , "#^+VK45": [A_ScriptDir "\PassPhrase\pass_phrase.ahk"]             ;vk45=e #^+e
                                            , "#VK4A":   [A_ScriptDir "\JDownloader.ahk"]                        ;vk4A=j #j
                                            , "#!VK4B":  [keepassahk,,,,-1]                  ;vk4B=k #!k
                                            , "#!+VK4B": [laPrograms "\WinAuth\WinAuth.exe"]                     ;vk4B=k #!+k
                                            , "#VK50":   [notepad2exe,""]                                        ;vk50=p #p
                                            , "#+VK50":  [notepad2exe,"/c /b"]                                   ;vk50=p #+p
                                            , "#!VK50":  [A_ScriptDir "\QuickText.ahk"]                          ;vk50=p #!p
                                            , "#VK54":   [A_ScriptDir "\WinActivateOrExec.ahk", laPrograms "\Telegram\telegram.exe"] ;vk54=t #t
                                            , "#!VK54":  [A_ScriptDir "\tombo.cmd",,,,7]                         ;vk54=t #!t
                                            ;, "#VK55":   [A_AhkPath, A_ScriptDir "\putty_smartact.ahk"]         ;vk55=u #u
                                            , "#VK56":   [vscode]                                                ;vk56=v #v
                                            , "#!VK53":  [A_ScriptDir "\EmailSelection.ahk",, ""]                ;vk53=s #!s
                                            , "Browser_Favorites": [A_ScriptDir "\Skype.cmd",,,,7]
                                            , "Launch_Mail": [A_ScriptDir "\EmailButton.ahk"] }
                                ; VK5A=Z, VK51=Q
                                , "#VK51":  { "^VK45":   [notepad2exe, """" A_ScriptFullPath """"]               ;vk45=e ^e
                                            , "^+VK45":  [notepad2exe, """" hotkeys_custom_ahk """"]             ;vk45=e ^+e
                                            , "#VK57":   [AU3_Spy]                                               ;vk57=w #w
                                            , "#VK52":   [A_ScriptDir "\ResizeOrRecord.ahk",,""]                 ;vk52=r #r
                                            , "#VK43":   [A_ScriptDir "\putty_connect.ahk"]                      ;vk43=c #c
                                            , "#VK50":   [A_ScriptDir "\putty_smartact.ahk"]                     ;vk50=p #p
                                            , "#+VK44":  [A_ScriptDir "\Dropbox.ahk"]                            ;vk44=d #+d
                                            , "F1":      [A_ScriptDir "\F1.ahk"]
                                            , "+F1":     [A_ScriptDir "\AutohotkeyHelp.ahk"] } }

    For altKey, HotkeysRunDelayed in RunDelayedGroups {
        If (altKey) {
            altMode := SubStr(altKey,-1) ; two last characters for label name are VK code, used as AlternateHotkeys code
            altFunc := Func("PrepareAltMode").Bind(altMode)
            Hotkey %altKey%, %altFunc%
            Hotkey If, AlternateHotkeys==0x%altMode%
        } Else {
            Hotkey If
        }
        For key,args in HotkeysRunDelayed {
            If (FileExist(args[1])) {
                SplitPath % args[1], , , OutExtension
                If (OutExtension = "ahk") {
                    args[2] := """" args[1] """ " args[2]
                    args[1] := A_AhkPath
                }
                hotkeyFunc := Func("RunDelayed").Bind(args*)
                HotKey %key%, %hotkeyFunc%
            } Else {
                FileAppend % "Not found: " args[1], *
            }
        }
    }
    If (altKey)
        HotKey If
}

RemoveToolTip:
    SetTimer RemoveToolTip, Off
    ToolTip
return

~LShift Up:: SwtichLang(layouts[1]) ; LOCALE_EN := 0x4090409
~RShift Up:: SwtichLang(layouts[2]) ; LOCALE_RU := 0x4190419
SwtichLang(newLocale) {
    Thread Priority, 1 ; No re-entrance
    If (A_ThisHotkey == "~" A_PriorKey " Up" && !WinActive("ahk_group NoLayoutSwitching")) {
        If ( InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinExist("A"), "UInt", 0), "UInt") ) {
            If (InputLocaleID != newLocale) { ; if language is not english XOR requested non-english
                ; WinGet ProcessName, ProcessName, A
                ; WinGetClass WinClass, A
                ; WinGet ProcessPath, ProcessPath
                ; ToolTip
                ; ToolTip %WinClass% %ProcessPath%
                If (WinActive("ahk_group NonStandardLayoutSwitching")) {
                    ToolTip Переключение раскладки через Win+Space
                    SendEvent #{Space}
                    Sleep 250
                    ToolTip
                } Else {
                    ControlGetFocus,ctl
                    PostMessage 0x50,3,%newLocale%,%ctl%,A ;WM_INPUTLANGCHANGEREQUEST - change locale, documentation https://msdn.microsoft.com/en-us/library/windows/desktop/ms632630.aspx
                    ; wParam
                    ; INPUTLANGCHANGE_BACKWARD 0x0004 A hot key was used to choose the previous input locale in the installed list of input locales. This flag cannot be used with the INPUTLANGCHANGE_FORWARD flag.
                    ; INPUTLANGCHANGE_FORWARD 0x0002 A hot key was used to choose the next input locale in the installed list of input locales. This flag cannot be used with the INPUTLANGCHANGE_BACKWARD flag.
                    ; INPUTLANGCHANGE_SYSCHARSET 0x0001 The new input locale's keyboard layout can be used with the system character set.
                }
            }
        }
    }
}

GetLayoutList() { ; List of system loaded layouts, from Lyt.ahk / https://autohotkey.com/boards/viewtopic.php?p=132600#p132600
    aLayouts := []
    size := DllCall("GetKeyboardLayoutList", "UInt", 0, "Ptr", 0)
    VarSetCapacity(list, A_PtrSize*size)
    size := DllCall("GetKeyboardLayoutList", Int, size, Str, list)
    Loop % size {
        aLayouts[A_Index] := NumGet(list, A_PtrSize*(A_Index - 1))
        ;aLayouts[A_Index].hkl := NumGet(List, A_PtrSize*(A_Index - 1))
        ;aLayouts[A_Index].LocName := this.GetLocaleName(, aLayouts[A_Index].hkl)
        ;aLayouts[A_Index].LocFullName := this.GetLocaleName(, aLayouts[A_Index].hkl, true)
        ;aLayouts[A_Index].LayoutName := this.GetLayoutName(, aLayouts[A_Index].hkl)
        ;aLayouts[A_Index].KLID := this.GetKLIDfromHKL(aLayouts[A_Index].hkl)
    }
    Return aLayouts
}

MoveToCornerNum(Corner, WindowSplitSize=2) {
    If Corner In 1,2,3
        VerticalSize:=WindowSplitSize
    If Corner In 7,8,9
        VerticalSize:=-WindowSplitSize
    If Corner In 1,4,7
        HorizontalSize:=-WindowSplitSize
    If Corner In 3,6,9
        HorizontalSize:=WindowSplitSize
    MoveToCorner(HorizontalSize,VerticalSize)
}

MoveToCorner(HorizSplit, VertSplit, MonNum := -1) {
    ; HorizSplit, VertSplit are as foolowing
    ;  0 = don't touch
    ;  1 = fullscreen,  2 = right/bottom half of screen, 3 = right/bottom third of screen, etc.
    ; -1 = fullscreen, -2 = left/top half of screen,    -3 = left/top third of screen, etc.
    ;  MonNum is monitor # as in SysGet, var, Monitor, #
    ; -1 for monitor of current window, "" for primary monitor
    
    IfWinNotExist A
        return
    
    ; Now get window position
    WinGetPos newX, newY, newW, newH

    If (MonNum == -1) {         ; If current window' monitor should be used, find it
        MonNum := FindWindowMonitorIndex(newX, newY, newW, newH)
        If (MonNum == "")       ; Primary monitor will be used instead
            TrayTip window @ (x%newX% y%newY% w%newW% h%newH%) is out of bounds,Cannot find current monitor,,0x22
    }
    
    SysGet MonWA, MonitorWorkArea, %MonNum%
    borderSize := 8
    If (HorizSplit) {
        newW := Abs((MonWARight - MonWALeft) / HorizSplit) + borderSize + borderSize
        If (HorizSplit<0)
            newX := MonWALeft - borderSize
        else
            newX := MonWARight - newW + borderSize
    }
    If (VertSplit) {
        newH := Abs((MonWABottom - MonWATop) / VertSplit) + borderSize + borderSize
        If (VertSplit < 0)
            newY := MonWATop - borderSize
        else
            NewY := MonWABottom - NewH + borderSize
    }
        
    WinMove,,, newX, newY, , 
    WinMove,,, , , newW, newH
    ; ToolTip newX: %newX% newY: %newY%`nnewW: %newW% newH: %newH%
}

PrepareAltMode(ByRef altMode) {
    global AlternateHotkeys
    AlternateHotkeys := "0x" altMode
    AlternateHotkeys+=0 ; +0 to ensure it's converted to number. Not necessary though.
    Tooltip %A_ThisHotkey% (%AlternateHotkeys%) ; / %A_ThisLabel%
    SetTimer AlternateHotkeysOff, -1000
}

AlternateHotkeysOff() {
    global AlternateHotkeys
    AlternateHotkeys:=""
    Tooltip
}

lReload:
    ToolTip
    ToolTip Reloading
    AlternateHotkeysOff()
    If (!(IsFunc("CustomReload") && Func("CustomReload").Call()))
        Reload
    Sleep 300 ; if successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox 4,, The script could not be reloaded. Would you like to open it for editing?
    IfMsgBox, Yes
        RunDelayed(notepad2exe " """ A_ScriptFullPath """")
return
    
lToggleWindowMonitor:
    If (WinActive("ahk_group WindowsActionCenter")) {
        MoveActionCenter()
        return
    }
    IfWinNotExist A
        return
    KeyWait LWin, L
    KeyWait RWin, L
    ;~ Send {LWin Up}{RWin Up}
    WinGetPos X, Y, W, H
    WinCentralPointX := X + W/2
    WinCentralPointY := Y + H/2
    
    ; ToDo: find current monitor, select next (get it from resizing func.)
    SysGet Monitor1Dimensions, Monitor, 1
    SysGet Monitor2Dimensions, Monitor, 2
    If ( ( WinCentralPointX > Monitor1DimensionsLeft ) && ( WinCentralPointX < Monitor2DimensionsLeft ) )
        X := X - Monitor1DimensionsLeft + Monitor2DimensionsLeft
    else
        X := X - Monitor2DimensionsLeft + Monitor1DimensionsLeft
    
    PostMessage, 0x112, 0xF120,,, A  ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
    Sleep 0
    WinMove %X%, %Y%
    Sleep 0

lMaximizeWindow:
    WinGet WinMinMaxState, MinMax, A
    If WinMinMaxState
        PostMessage, 0x112, 0xF120,,, A ; 0x112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE
    Else
        PostMessage 0x112, 0xF030,,, A  ; 0x112 = WM_SYSCOMMAND, 0xF030 = SC_MAXIMIZE
    ; ToDo: restore window original position
    return

RunDelayed(ByRef params*) { ; File [, Arguments, Directory, Operation, Show]; Show is as in ShellRun or -1 to run as ahk script (w/o ShellRun)
    static runQueue := []
    
    If (IsObject(params) && nparams := params.Length()) {
        AlternateHotkeysOff()
        RunQueue.Push((nparams==1) ? params[1] : params)
        SetTimer %A_ThisFunc%, 100
        ToolTip % "Added " ((nparams==1) ? params[1] : params) " to launch queue"
        SetTimer RemoveToolTip, 1000
        return
    } Else {
        If (cmd := runQueue.Pop()) {
            If (IsObject(cmd)) { ; not only executable name
                If (cmd[5] == -1)
                    RunAndActivate(cmd*)
                Else
                    nprivRun(cmd*)
            } Else { ; only executable name, with no parameters or workdir
                If (FileExist(cmd)) {
                    SplitPath cmd, exename, wd, ext
                    ; this does not find any window running under other user / non-admin :: UniqueID := WinExist("ahk_exe" exename)
                    If (ext == "exe" && (UniqueID := WinExist("ahk_exe " exename)) && !WinActive("ahk_id " UniqueID)) {
                        WinGet state, MinMax, ahk_exe %exename%
                        If (state == -1)
                            WinRestore ahk_exe %exename%
                        WinActivate
                        ToolTip % "Activated " cmd
                        SetTimer RemoveToolTip, 1000
                    } Else {
                        cmdAndArgs := ext = "ahk" ? [A_AhkPath, """" cmd """"]
                                       : ext = "cmd" ? [comspec, " /C """ cmd """"]
                                       : ["", cmd]
                        RunAndActivate(cmdAndArgs*)
                    }
                } Else {
                    RunAndActivate("", cmd)
                }
            }
        } Else {
            SetTimer ,,Off
        }
    }
}

ObjectToText(ByRef obj) {
    return IsObject(obj) ? ObjectToText_nocheck(obj) : obj
}

ObjectToText_nocheck(obj) {
    out := ""
    For i,v in obj
        out .= i ": " ( IsObject(v) ? "(" ObjectToText_nocheck(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

RunAndActivate(tgt, ByRef args := "", ByRef wd := "", ByRef options := "") {
    If (!wd)
        wd := A_Temp
    If (tgt) {
        If (InStr(tgt, " "))
            tgt = "%tgt%"
        tgt .= A_Space
    }
    Run %tgt%%args%, %wd%, %options%, r_PID
    WinWait ahk_PID %r_PID%,,3
    If (!ErrorLevel)
        WinActivate
    Tooltip Started and activated %tgt%
    SetTimer RemoveToolTip, 1000
}

PasteViaClip(t) {
    If (!clipBak)
        clipBak:=ClipboardAll
    Clipboard:=t
    Sleep 100
    Send +{Ins}
    Sleep 300
    Clipboard:=clipBak
    clipBak=
}

StrJoin(separator := "", strings*) {
    o := ""
    For i, str in strings
        o .= str . separator
    Return StrLen(separator) ? SubStr(o, 1, -StrLen(separator)) : o
}

GetOSVersion() {
    ; From http://www.autohotkey.com/board/topic/54639-getosversion/
    Return ((r := DllCall("GetVersion") & 0xFFFF) & 0xFF) "." (r >> 8)
}

FirstExisting(paths*) {
    For i, path in paths
        If (FileExist(path))
            return path
    Return ""
}

#include <nprivRun>
