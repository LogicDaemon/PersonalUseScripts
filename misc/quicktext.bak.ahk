;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

#NoEnv
#SingleInstance force
FileEncoding UTF-8

SetTitleMatchMode RegEx

GroupAdd Notepad2Boilerplates, ahk_class \bNotepad2\b
GroupAdd Notepad2Boilerplates, ahk_class \bNotepad2U\b
;For _, ext in ["bat", "cmd", "ahk", "url"]
;    GroupAdd Notepad2Boilerplates, \.%ext%\b ahk_class \bNotepad2%classSuffix%\b

If (WinActive("ahk_group Notepad2Boilerplates"))
    PasteNotepad2Boilerplate()

; Despite RegEx above, %exe% is still plaintext. \b and \. make this not match the putty.
For _, exe in ["cmd.exe","putty.exe"]
    GroupAdd PasteViaShiftInsert, ahk_exe %exe%

;FileRead QuickText, QuickText.txt
;StringReplace QuickText, QuickText, `r`n, |, UseErrorLevel

;Gui Add, ListBox, vPasteText, %QuickText%
;Gui Add, Button, Default, OK
;Gui Show

;Exit

;ButtonOK:
;    Gui Submit
;    SendRaw %PasteText%

;GuiClose:
;GuiEscape:
;    ExitApp

; ---------------------------------------------------------------------
; Name:  			Search&Paste
; Author:           Boskoop
; Datum:            23.3.06
; Modified 2012-07-01 by LogicDaemon for its own sake
; ---------------------------------------------------------------------
; Kollektor sammelt Textbausteine. Text markieren, CTRL-CapsLock drücken. Der Text wird
; an die Liste Collection.txt angehängt.
; Zeilenumbrüche werden durch das Zeichen ¤ ersetzt. ¤ ist gleichzeitig Trennzeichen
; für Tabellenspalten. Mit dem ViewMode 1-2-3-4... werden die Zeilenumbrüche wieder restauriert.
;
; KURZANLEITUNG:
; Programm starten. Kollektor wartet jetzt im Hintergrund darauf, daß er aufgerufen wird.
;
; Text markieren. CTRL-CapsLock. Der markierte Text wird der Liste angefügt.
; Die Taste CapsLock ruft Kollektor auf.
; Man tippt das gesuchte Wort ein. In der Liste werden nur die Treffer angezeigt.
; Mit den Pfeiltasten "rauf" und "runter" kann durch die Liste navigieren.
; Im Vorschaufenster wird ein größerer Ausschnitt des Textes angezeigt
; Mit dem Druck auf die Enter-Taste wird der Inhalt des Vorschau-Fensters an Cursorposition eingefügt.
; Das Kollektor-Fenster verschwindet automatisch.
; Kollektor wird mit ALT-F4 oder per Rechtsklick auf das Icon und Klicken auf den Menüpunkt
; Exit beendet.
; ---------------------------------------------------------------------

; VARIABLEN
;
; Hitlist: Suchen in der Datenbank: Liste der Zeilen mit Treffern. Wird von der Funktion SearchDB() erzeugt
; Hitlist_N: Array. An der N-ten Position der Trefferliste steht die Zeile X. Z. B. Hitlist=1|4|8 Hitlist_3=8. Wird von der Subroutine Eingabe: erzeugt
;
; Word: Inhalt der 1. Zelle einer Trefferzeile. Von Subroutine Eingabe: erzeugt
; Wordlist: Liste von Wörtern der 1. Zelle aller Trefferzeilen .Z. B. rot|grün|blau. Von Subroutine Eingabe: erzeugt
;
; Choice: Position des augewählten Items in der Listbox bzw. in der Hitlist. Von der Listbox in der GUI erzeugt (vChoice) oder von der Subroutine Eingabe auf 1 gesetzt.
; Treffer: ist die Datenbankzeile des ausgewählten Listenitems. Lokale Variable der Funktion ShowDBLine()
;
; LineCount: Zeilenzahl in der Liste/ Tabelle. Von ReadDBFile(DatabaseFile) erzeugt.
;
; ViewOrder: Die anzuzeigenden Datenbankzellen mit der Syntax 1-2-3, Trenner zwischen Anzeigemodi: | Return: 1-2, Leerzeichen, kein Return: 1_-2 Leerzeichen Komma, kein Return 1,_-2
; ModeNr: Die Nummer eines Anzeigemodus
; Direction: Nächster/ Letzter Anzeigemodus
;
; CursorIn :Die Control, in der sich beim GUI-Start der Cursor befindet
; ActiveWindow :Das beim GUI-Start aktive Fenster
;
; GUIStartKey: Hotkey, mit dem die GUI gestartet wird. Wird in der INI definiert. Default: Capslock

;****************************************************
;*                                                  *
;*           INITALISIERUNG							*
;*													*
;****************************************************


;Initialisierung
SetTitleMatchMode, 3
#KeyHistory 0

ReadIni()					;Liest die .ini-Datei mit den Optionen ein


GUITitle=QuickText			;Vorsicht, wenn das geändert wird, funktionieren die Hotkeys <- und -> nicht mehr!
Separator=¤
DBFile=%A_MyDocuments%\QuickText.txt
;Editor=notepad.exe
ModeNr=1
Direction=0

;Menu, tray, icon, SearchNPaste.ico
;Hotkey, %GUIStartKey%, GUIStart
;****************************************************
;*                                                  *
;*           AUTOEXECUTE							*
;*													*
;****************************************************

GUIStart:
;Datenbank auslesen
ReadDBFile(DBFile, Separator)
StartList := MakeStartList()

; Aktives Fenster und aktive Control bestimmen
CursorIn := GetActiveControl()
ActiveWindow := GetActiveWindow()

;Verhindert Fehlermeldung, wenn das Fenster im Hintergrund schon aktiv ist
If (WinExist(GUITitle)) {
	If (!WinActive(GUITitle)) {
		WinMinimize
		WinActivate
	}
	;Gui destroy
} else {
    Gui, Add, Edit, gEingabe vEingabe x50 y5 w115 h20  +Left,
    Gui, Add, ListBox, x5 y35 w160 h260 gChoice vChoice altsubmit ,%StartList%
    Gui, Add, Edit, x5 y315 w160 h90 ReadOnly,
    Gui, Add, Button, x5 y410 w40 h20 Default, &OK
    Gui, Add, Button, x15 y290 w60 h20 , &Edit List
    Gui, Add, Text, x5 y8 w45 h15, &Search:

    Gui, Show, x353 y211 h435 w171,QuickText

    ; Erstellt eine Hitlist und einen Hitlist-Array, damit bereits beim GUI-Start die Datenbankfelder in der Edit 2 angezeigt werden können.
    Choice=1
    loop, %LineCount%
    {
            Hitlist=%Hitlist%|%A_Index%
            Hitlist_%A_Index%=%A_Index%
    }

    ModeNr=1
    Direction=0
    ;Anzeige(ViewOrder,ModeNr,Direction)
    Show()
}
Return



;****************************************************
;*                                                  *
;*           HOTKEYS								*
;*													*
;****************************************************

#IfWinActive, QuickText ahk_class AutoHotkeyGUI	;Hotkeys gelten nur für die oben erzeugte GUI

Up::
Gui +LastFound
ControlSend, ListBox1, {Up}
return

Down::
Gui +LastFound
ControlSend, ListBox1, {Down}
return

#IfWinActive

;Mit CTRL-Capslock werden markierte Texte in den File Collection.txt geschrieben
;#!Ins::
;ClipText := Clipboard
;;StringReplace ClipText, ClipText, `r`n,¤, All ;Replaces CR LF by ¤
;FileAppend %ClipText%`n, Collection.txt
;ClipText=
;Return


;****************************************************
;*                                                  *
;*           SUBROUTINEN                            *
;*													*
;****************************************************

ButtonOK:		;Fügt den ausgewählten Text in die Anwendung ein
	Critical
	ControlGetText cb,Edit2
	GUI destroy
	PasteViaClipboard(cb)
GuiEscape:		;GUI verschwindet, Programm bleibt im Speicher
GuiClose:		;Programm wird beendet
	ExitApp

; --------------------------------------------------------------------------

ButtonOptions:
	runwait, notepad.exe "%A_ScriptFullPath%"
	sleep, 500
	ReadIni()
	return

ButtonEditList:
	runwait, *Edit %DBFile%
	GUI destroy
	Gosub GUIStart
	return

; --------------------------------------------------------------------------

EINGABE:
; Wird bei jeder Eingabe ins Suchfeld aufgerufen.
; Zeigt die Trefferliste zum Suchbegriff in der Listbox an.
Gui, Submit, noHide
SearchFor=
Loop
{	; Manchmal tippt man zu schnell für den Computer...
	If SearchFor=%Eingabe%
		break
	SearchFor=%Eingabe%

	;Erstellen der Trefferliste
	Hitlist := SearchDB(SearchFor,CaseSensitive,WholeWordCheck,WhichColumn,WordStart)
	word=
	wordlist=
	loop, parse, Hitlist,|
	{
		Word := DB%A_LoopField%_1
		Wordlist =%Wordlist%|%word%
		Hitlist_%A_Index%=%A_LoopField%
	}

	; Nachgucken, ob nicht doch noch eine Eingabe erfolgt ist...
	GUI, Submit, noHide
}

; Spezialfälle werden behandelt
If (Wordlist="")			;Kein Treffer für den Suchbegriff: Die Listbox wird geleert.
	Wordlist=|

If (SearchFor="")			;Zeigt die Ausgangsliste an, wenn alle Eingaben gelöscht sind
	Wordlist=|%StartList%

; Listbox mit Trefferliste wird angezeigt
GuiControl,, ListBox1, %wordlist%
Choice=1
Direction=0
ModeNr=1
;Anzeige(ViewOrder,ModeNr, Direction)
Show()
return

; --------------------------------------------------------------------------

CHOICE:
; Wird beim Navigieren in der Listbox aufgerufen.

Gui, submit, NoHide
Direction=0
ModeNr=1
;Anzeige(ViewOrder,ModeNr,Direction)
Show()

;Doppelklick auf ein Item: Wie ButtonOK:
if A_GuiControlEvent = DoubleClick
    Gosub ButtonOK
return



;****************************************************
;*                                                  *
;*            GUI_FUNKTIONEN						*
;*													*
;****************************************************

Show()
; Zeigt den Textbaustein im Vorschaufenster an. Restauriert die Zeilenumbrüche vor dem Senden.
{
	global  Hitlist, Choice,
	Treffer := Hitlist_%Choice%			; "Treffer" ist die Nummer der Datenbankzeile des ausgewählten Listenitems
	Line := DBLine_%Treffer%
	StringReplace, ToShow, Line, ¤, `n, All
	GuiControl,, Edit2, %ToShow%
	return
}


Anzeige(ViewOrder,ModeNr, Direction)
; Zeigt die Feldinhalte in Edit2 formatiert an und erlaubt, zwischen verschiedenen Anzeigemodi der Feldinhalte zu wechseln.
; ViewOrder: 	1-2-3 	(Felder 1, 2 und 3 werden in eigenen Zeilen angezeigt)
;				1_-2-3	(Felder 1 und 2 werden in der gleichen Zeile, durch Leerzeichen getrennt angezeigt)
;				1,_-2-3	(Felder 1 und 2 werden in der gleichen Zeile, durch Komma und Leerzeichen getrennt angezeigt)
; ModeNr: Nummer des gerade angezeigten Modus
; Direction: Nächster oder vorheriger Modus.
; Lokale Variablen: a (Zählvariable), ToShow_%a%(Anzuzeigender Inhalt)
{
	global ColCount, Hitlist, Choice

	Treffer := Hitlist_%Choice%			; "Treffer" ist die Datenbankzeile des ausgewählten Listenitems

	ModeNr := ModeNr+Direction

	ViewModeCount=0
	loop, parse,ViewOrder,|
		{
			ViewModeCount := ViewModeCount + 1		;Zählt die Anzeigen-Modi
			a=%A_Index%
			ToShow_%a% =

			Loop, Parse,A_LoopField,-
			{
				If A_LoopField is integer
				{
					ToShow_%a% := ToShow_%a% . DB%Treffer%_%A_LoopField% . "`n"
				}

				else
				{
					FieldNr := LeaveOnlyNumbers(A_LoopField)				;Nur die Feldnummer bleibt übrig, alle anderen Zeichen werden entfernt
					if (Instr(A_LoopField,",_")>0)							;Komma Unterstrich für Komma, Leerzeichen,kein Zeilenumbruch
						ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . "," . A_Space
					else if (Instr(A_LoopField,"_")>0)						;Unterstrich für, Leerzeichen,kein Zeilenumbruch
						ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . A_Space
					else
						ToShow_%a% := ToShow_%a% . DB%Treffer%_%FieldNr% . "`n"		;Alle weiteren Nicht-Integers werden ignoriert
				}

			}
		}

	; Am Listenende: Sprung an den Anfang/ Am Listenanfang: Sprung ans Ende der Liste
	If (ModeNr<1)
		ModeNr= %ViewModeCount%
	If (ModeNr>ViewModeCount)
		ModeNr=1

	;Anzeige des gewählten Modus
	GuiControl,, Edit2, % ToShow_%ModeNr%

	;Rückgabe der ModusNummer
	Return ModeNr
}

; --------------------------------------------------------------------------

MakeStartList()
;erstellt eine Liste aller Items, die beim Programmstart angezeigt wird
{
	global LineCount
	Startlist=
	Loop, %LineCount%
	{
		word := DB%A_Index%_1
		Startlist =%Startlist%%word%|
	}
	return StartList
}


;****************************************************
;*                                                  *
;*            SUCH-FUNKTIONEN						*
;*													*
;****************************************************

SearchDB(SearchFor,CaseSensitive,WholeWordCheck,WhichColumn,WordStart)
; Sucht nach dem als Parameter (SearchFor) übergebenen String. Gibt die Zeilen, in der
; der Suchstring gefunden wurde, als Liste der Zeilennummern im Format 1|3| u.s.w. zurueck ("Hitlist")

; Der Parameter CaseSensitive bestimmt, ob bei der Suche die Groß/Kleinschreibung beachtet wird.

; Der Parameter WholeWordCheck bestimmt, ob bei der nur nach ganze Wörtern (on) oder auch nach
; Wortfragmenten gesucht wird. Zum Prüfen wird die Funktion IsWholeWord(SearchIn,SearchFor) aufgerufen.
;
; Der Parameter WhichColumn gibt an, welche Spalten durchsucht werden sollen. ALL=Alle Spalten.
; 1 oder 2 oder ...: Die explizit benannte Spalte. Default ist 1

; Der Parameter WordStart bestimmt, ob der Suchtext am Zellenanfang stehen muß.
;
; Die Parameterübergabe (global, local, was muss deklariert werden, was nicht) ist etwas unlogisch.
; Näheres in der AHK-Dokumentation (Functions-Local Variables and Global Variables)

{
	global LineCount, ColCount			;Bestehende globale Variablen müssen bei Verwendung innerhalb einer Funktion als global deklariert werden
	;global counter
	;Counter := counter+1

	; FEHLERBEHANDLUNG
	If (WhichColumn>ColCount and WhichColumn<>"ALL")			;Suche in einer nicht existierenden Spalte
		{
			msgbox, Die Tabelle enthält nur %ColCount% Spalten.`nDie %WhichColumn%. Spalte kann also nicht durchsucht werden.`nDie Anwendung wird beendet.
			exitapp
		}

	; SUCHE
	Loop, %LineCount%
	{
		L_Index=%A_Index%				;L_Index: Zeilennummer

		Loop, %ColCount%
		{
			;In welchen Spalten?
			If WhichColumn=ALL			;Alle Spalten werden durchsucht
				C_Index=%A_Index%		;C_Index: Spaltennummer
			Else
				C_Index=%WhichColumn%	;nur die spezifizierte Spalte wird durchsucht

			SearchIn :=  DB%L_Index%_%C_Index%
			Position := InStr( SearchIn,SearchFor,CaseSensitive )		;Position des Suchbegriffes. O= Suchbegriff nicht gefunden. >=1 Treffer irgendwo in SearchIn. =1 Treffer steht am Anfang

			If (Position = 0)
				continue

			;Bedingungen abfragen
			If (Position=1 AND WholeWordCheck="ON" AND WordStart="ON")		;Es wird nach ganzem Wort am Zellanfang gesucht
			{
				WholeWord := IsWholeWord(SearchIn,SearchFor)
				If WholeWord=1
				{
					Hitlist=%Hitlist%%L_Index%|
					break
				}
			}

			If (Position>=1 AND WholeWordCheck="ON" AND WordStart="OFF")	;Es wird nach ganzem Wort irgendwo in der Zelle gesucht
			{
				WholeWord := IsWholeWord(SearchIn,SearchFor)
				If WholeWord=1
				{
					Hitlist=%Hitlist%%L_Index%|
					break
				}
			}

			If (Position=1 AND WholeWordCheck="OFF" AND WordStart="ON")	;der Zelleninhalt beginnt mit dem Suchbegriff
			{
				Hitlist=%Hitlist%%L_Index%|
				break
			}

			If (Position>=1 AND WholeWordCheck="OFF" AND WordStart="OFF")	;Suchbegriff hat beliebige Position
			{
				Hitlist=%Hitlist%%L_Index%|
				Break
			}
			If (WhichColumn<>"ALL")		;Beendt die Suche nach einer Spalte, wenn nur eine durchsucht werden soll
			{
				Break
			}
		}
	}
	return Hitlist
}


;***************************************************************************************************

ReadDBFile(DatabaseFile,Separator)
; Schreibt den Inhalt einer Semicolon-getrennten Datenbankdatei in ein Array.
; Array-Syntax:DBZeilennummer_Spaltennummer=Feldinhalt
; DBLine_Zeilennummer: Zeileninhalt
; Liefert außerdem die Anzahl von Zeilen und Spalten in der Datenbank-Datei zurück (ebenfalls als globale Variablen).
; Die Funktion hat keinen direkten Rückgabewert.
;
; GLOBALE VARIABLEN:
; LineCount: Anzahl der Zeilen in der Datenbank-Datei
; ColCount: Spaltenzahl (Anzahl der Felder in der längsten Zeile)
; DB%L_Index%_%A_Index%: Array, in dem die Datenbankfelder gespeichert sind: Zeilennummer_Spaltennummer
; %L_Index%ColCount: Spaltenzahl in der L-ten Zeile. Wird nicht weiter gebraucht, läßt sich aber leider auch nicht als lokale Variable definieren

{
	global							;Alle Variablen dieser Funktion sind global
	local L_Index					;Diese Variablen sind lokal (gelten nur innerhalb der Funktion)
	LineCount = 0
	ColCount = 0


	;Krücke. Nach dem Löschen der Liste bleibt das Array im Speicher. Die 1. Zeile wird geleert, um zu verhindern, daß sie in der Edit2 angezeigt wird.
	IfNotExist, %DBFile%
		DBLine_1 =

	Loop, read, %DBFile%
	{
		DBLine_%A_Index%=%A_LoopReadLine%
		L_Index=%A_Index%
		%L_Index%ColCount = 0
		LineCount += 1
		Loop, parse, A_LoopReadLine,%Separator%
		{
			DB%L_Index%_%A_Index% = %A_LoopField%
			%L_Index%ColCount += 1			;Die Variable %L_Index%ColCount ist NICHT identisch mit ColCount!
			if( ColCount < %L_Index%ColCount )
				ColCount := %L_Index%ColCount
		}
	}

}


;*******************************************************************************************************

IsWholeWord(SearchIn,SearchFor)
; Überprüft ob der zu suchenden Begriff "SearchFor" als eigenes vollständiges Wort in "SearchIn"
; vorkommt.
; Wenn ja, wird WholeWord=1 zurückgegeben, wenn nicht WholeWord=0
{
	BorderChar=,,,.,%A_Space%,%A_Tab%,-,:				;Liste von Zeichen, die vor oder nach einem Wort stehen können. Reihenfolge der Liste ist wichtig!
	SearchLength := StrLen(SearchFor)
	FieldLength := StrLen( SearchIn)
	Position := InStr( SearchIn, SearchFor)

	if SearchLength = %FieldLength%				 	;SearchIn enthält nur das Suchwort
	{
		WholeWord=1
	}

	else if Position=1								;SearchIn beginnt mit dem Suchwort
	{
		StringMid, TailChar, SearchIn, % Position+SearchLength, 1	;TailChar: erstes Zeichen nach "SearchFor"
		if TailChar contains %BorderChar%
		{
			WholeWord=1
		}
		else
		 {
		 	WholeWord=0
		 }
	}

	else if (Position+SearchLength-1=FieldLength)	;SearchIn endet mit dem Suchwort
	{
		StringMid, LeadChar, SearchIn, % Position - 1, 1
		if LeadChar contains %BorderChar%
		{
			WholeWord=1
		}
		else
		{
		 	WholeWord=0
		}
	}

	else											;SearchFor steht mitten in SearchIn
	{
		StringMid, LeadChar, SearchIn, % Position - 1, 1
		if LeadChar contains %BorderChar%
		{
			StringMid, TailChar, SearchIn, % Position+SearchLength, 1	;TailChar: erstes Zeichen nach "SearchFor"
			if TailChar contains %BorderChar%
			{
				WholeWord=1
			}
			else
			{
				WholeWord=0
			}
		}
		else
		{
		 	WholeWord=0
		}
	}
	return WholeWord
}


;****************************************************
;*                                                  *
;*            SONSTIGE FUNKTIONEN					*
;*													*
;****************************************************

LeaveOnlyNumbers(String)
;Entfernt alle Zeichen außer den Ziffern aus dem String
{
	stringlen, Laenge, String
	stringsplit, Stringarray, string
	Loop, %Laenge%
	{
	if stringarray%A_Index% is not integer
		{
		Stringarray%A_Index%=
		}
		x:= stringarray%A_Index%
		NewString=%NewString%%x%
	}
	String=%NewString%
	Return %String%
}

; --------------------------------------------------------

CharacterCount(String, Character)
;Zählt, wie oft das Zeichen "Character" im String vorkommt und gibt diese Anzahl zurück
{
	x=0
	stringlen, Laenge, String
	stringsplit, Stringarray, string
	Loop, %Laenge%
	{
	if stringarray%A_Index% contains %Character%
		{
		x := x+1
		}
	}
	Return x
}

; --------------------------------------------------------

GetActiveControl()
;Gibt den Namen der aktiven Control zurück
{
WinGet, Active_Window_ID, ID, A
ControlGetFocus, ActiveControl, A,
Return,  ActiveControl
}

; --------------------------------------------------------

GetActiveWindow()
; Gibt die ID-Nummer des gerade aktiven Fensters zurück
{
WinGet, Active_Window_ID, ID, A
return, Active_Window_ID
}

; --------------------------------------------------------
ReadIni()
; Liest die Kollektor.ini ein
{
	global
	;IniRead, DBFile, %IniFile%, FILE, File,
;	IniRead CaseSensitive,	%IniFile%, SEARCH,	CaseSensitive,0
;	IniRead WholeWordCheck,	%IniFile%, SEARCH,	WholeWordCheck,OFF
;	IniRead WordStart,	%IniFile%, SEARCH,	WordStart,OFF
;	IniRead WhichColumn,	%IniFile%, SEARCH,	WhichColumn,1
;	IniRead GUIStartKey,	%IniFile%, MISC,	GUIStartKey,CAPSLOCK
	;IniRead Separator,	%IniFile%, MISC,	Separator,`;
;	IniRead ViewOrder,	%IniFile%, VIEW,	ViewOrder, 1-2-3-4-5
	CaseSensitive=0
	WordStart=OFF
	WholeWordCheck=OFF
	WhichColumn=1
	GUIStartKey=CAPSLOCK
	Separator=`;
	ViewOrder=1-2-3-4-5
}

PasteNotepad2Boilerplate() {
    StatusBarGetText FileSize, 2
    If ( FileSize != "0 bytes" && FileSize != "0 байт" ) {
	TrayTip Ignoring boilerplating,Size = %FileSize%`, should be 0.,2
	return
    }

    WinGetTitle winTitle
    extPos := RegexMatch(winTitle, "\.(...)\s", mExt)
    If (!extPos) {
	TrayTip No extension found in title,Size = %FileSize%`, should be 0.,2
        return
    }
    bp := GetBoilerplate(mExt1)
    If (!bp) {
	TrayTip No boilerplate for %mExt%,Size = %FileSize%`, should be 0.,2
        return
    }
    PasteViaClipboard(bp)

    Send {F9}
    WinWait Encoding ahk_class #32770
    ;PostMessage 0x185, 1, 2, SysListView321 ; Select all listbox items. 0x185 is LB_SETSEL
    If mExt1 in cmd,bat
    {
        ;Control ChooseString, OEM (866)
        ControlSend SysListView321, {Home}{Down}
    } Else If (ext = "url") {
        Control ChooseString, Unicode (UTF-16 LE BOM)
    } Else {
        ; fails to select actually this: Control ChooseString, UTF-8 Signature
        ControlSend SysListView321, {Home}utf-8 sig
    }
    Sleep 50
    ControlSend,, {Enter}
    ExitApp
}

PasteViaClipboard(ByRef data) {
    clipBackup:=ClipboardAll
    Clipboard := data
    ClipWait 3,1

    ;If WinActive("Zero-K ahk_exe spring.exe") {
    ;    SendEvent ^v
    ;} Else
    If (WinActive("ahk_group PasteViaShiftInsert")) {
        SendEvent +{Insert}
    } Else {
        SendEvent ^v  ; ^{VK56}
    }
    Sleep 100
    Clipboard:=clipBackup
}

GetBoilerplate(ext) {
    authorship=by LogicDaemon <www.logicdaemon.ru>
    license=This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.
    ext := Format("{:L}", ext)
    If (ext == "url")
        v = [InternetShortcut]`nURL=`n
    Else If (ext == "ahk")
        v =
	( LTrim
        ;%authorship%
        ;%license%
        #NoEnv
        FileEncoding UTF-8

        EnvGet LocalAppData,LOCALAPPDATA
        EnvGet SystemRoot,SystemRoot
        `n
	)
    Else If ext in cmd,bat
        v =
        ( LTrim
        @(REM coding:CP866
        REM %authorship%
        REM %license%
        SETLOCAL ENABLEEXTENSIONS
        `)
        `n
	)
    return v
}
