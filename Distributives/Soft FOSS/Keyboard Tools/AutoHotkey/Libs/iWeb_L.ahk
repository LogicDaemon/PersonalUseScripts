;~ This library is the Product of tank
;~ based on COM.ahk from Sean http://www.autohotkey.com/forum/topic22923.html
;~ standard library is the work of tank and updates may be downloaded from
;~ http://www.autohotkey.net/~tank/iWeb.zip
;~ http://www.autohotkey.com/forum/viewtopic.php?t=51270

;~ complete API
/*
iWeb_newIe()
iWeb_Model(h=550,w=900)
iWeb_getwin(Name="")
iWeb_nav(pwb,url)
iWeb_complete(pwb)
iWeb_DomWin(pDisp,frm="")
iWeb_inpt(i)
iWeb_getDomObj(pwb,obj,frm="")
iWeb_setDomObj(pwb,obj,t,frm="")
iWeb_Checked(pwb,obj,checked=1,sIndex=0,frm="")
iWeb_SelectOption(pDisp,sName,selected,method="selectedIndex",frm="")
iWeb_TableParse(pDisp,table,row,cell,frm="")
iWeb_FireEvents(ele)
iWeb_TableLength(pDisp,TableRows="",TableRowsCells="",frm="")
iWeb_clickDomObj(pwb,obj,frm="")
iWeb_clickText(pwb,t,frm="")
iWeb_clickHref(pwb,t,frm="")
iWeb_clickValue(pwb,t,frm="")
iWeb_execScript(pwb,js,frm="")
iWeb_getVar(pwb,var,frm="")
iWeb_escape_text(txt)
iWeb_striphtml(HTML)
iWeb_Txt2Doc(t)
iWeb_Activate(sTitle)
*/
;~~~~~ Library initialisers ~~~~~
;~~~~~ getting/destroying browser handles ~~~~~

	;~ A new internet explorer window
	iWeb_newIe()
	{
		Return	pweb := (pweb := COM_CreateObject("InternetExplorer.Application") ) ? (pweb,pweb.visible := True) : 0
	}
	;~ New internet explorer window always on top with titlebar only
	iWeb_Model(h=550,w=900)
	{
		;"False" ;"True" ;uncomment to show
	;~ 	COM_Invoke(pwb,"ToolBar",1)
		If	pwb := (pwb := iWeb_newIe()) ? (pwb,pwb.menuBar:=0,pwb.AddressBar:=0,pwb.statusBar:=0,pwb.height:=h,pwb.width:=w) : 
		WinSet,AlwaysOnTop,On,% "ahk_class " pwb.hwnd
		Return	pwb
	}
	;~ reuse an existing tab or window
	iWeb_getWin(Name="")
	{
		IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame ; Get active window if no parameter 
			Name := RegExReplace(Name," - (?:Windows|Microsoft) Internet Explorer")
		if name
			If psw := COM_CreateObject("Shell.Application").Windows {
				COM_Error(False)
				Loop, %	psw.Count
					If pwb := (InStr(psw.item[A_Index-1].LocationName,Name) && InStr(psw.item[A_Index-1].FullName, "iexplore.exe")) ? psw.item[A_Index-1] :
						Break
				COM_Error(True)
			}
		Return pwb	
	}

	;~ Navigate to a url
	iWeb_nav(pwb,url)						; returns bool 
	{
		If  !pwb {		;	test to see if we have a valid interface pointer
			MsgBox, 262160, Browser Navigation, The Browser you tried to Navigate to `n%url%`nwith is not valid
			Return						;	ExitApp if we dont
		}
		;~ 	http://msdn.microsoft.com/en-us/library/aa752133(VS.85).aspx
		navTrustedForActiveX = 0x0400
		COM_Invoke(pwb,	"Navigate",	url,	navTrustedForActiveX,	"_self")
		iWeb_complete(pwb)
		Return							;	return the result(bool) of the complete function 
	}									;	nav function end

	;~ wait for a page to finish loading
	iWeb_complete(pwb)						;	returns bool for success or failure
	{	
		If  !pwb							;	test to see if we have a valid interface pointer
			return False						;	ExitApp if we dont
	Loop 20							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
		If !(pwb.readyState = 4)
			Break				;	return success
		Else	Sleep,100					;	sleep .1 second between cycles
	Loop 80							;	sets limit if itenerations to 40 seconds 80*500=40000=40 secs
		If (pwb.readyState = 4)
			Break
		Else	Sleep,500					;	sleep half second between cycles
	Loop	80				
		If (pwb.document.readystate="complete")
			Return 	1				;	return success
		Else	Sleep,100
		Return 0						;	lets face it if it got this far it failed
	}								;	end complete

	;~ get the window onject from an object
	iWeb_DomWin(pdsp,frm="")
	{

		qsid:="{332C4427-26CB-11D0-B483-00C04FD90119}"
		If !pWin := COM_QueryService(pdsp, qsid, qsid)
			return False
		if frm {
			Loop, Parse, frm, `, 
			{
				frame:=pWin.document.all.item[A_LoopField].contentwindow
				pWin:=COM_QueryService(frame, qsid, qsid)
				If !pWin
					Return False
			}
		}
		Return COM_Enwrap(pWin)
	}

	;~ Determine if an element is a form input 
	iWeb_inpt(i)
	{
		;~ 	http://msdn.microsoft.com/en-us/library/ms534657(VS.85).aspx tagname property
		typ := i.tagName
		inpt := "BUTTON,INPUT,OPTION,SELECT,TEXTAREA" ; these things all have value attribute and is likely what i need instead of innerHTML
		Loop,Parse,inpt,`,
			if (typ = A_LoopField ? 1 : "")
				Return 1
		Return
	}


;~~~~~ Functions that manipulate DOM ~~~~~

	iWeb_getDomObj(pdsp,obj,frm="")
	{

		If !pWin := frm ? iWeb_DomWin(pdsp,frm) : iWeb_domWin(pdsp)
			return False
		If  col := pWin.document.all	
		{
			Loop,Parse,obj,`,
			{
				If itm := col.item[A_LoopField]	; if this fails there really isnt any need to do below
				{
					tx := iWeb_inpt(itm) ? itm.value : itm.innerHTML
					StringReplace,tx,tx,`,,&#44;,all	; escape all commas in text extracted always
					rslt .= tx ","
					iWeb_FireEvents(itm)
				}
			}
			StringTrimRight, rslt, rslt, 1		; strip trailing comma
		}
		Return rslt
	}

	iWeb_setDomObj(pdsp,obj,t,frm="")
	{

		If !pWin := frm ? iWeb_DomWin(pdsp,frm) : iWeb_domWin(pdsp)
			return False
		If  col := pWin.document.all 
		{
			StringSplit,tt,t,`,
			Loop,Parse,obj,`,
			{
				If itm := col.item[A_LoopField] ; if this fails there really isnt any need to do below
				{
					StringReplace,tt%A_Index%,tt%A_Index%,&#44;,`,,all	;	unescape all commas in text extracted always
					; 	COM_Invoke(itm, v := iWeb_inpt(itm) ? "value" : "innerHTML",COM_Parameter(8, tt%A_Index%))
					iWeb_inpt(itm) ? (itm.value:=COM_Parameter(8, tt%A_Index%)) : (itm.innerHTML:=COM_Parameter(8, tt%A_Index%))
					iWeb_FireEvents(itm)
					d=1
				}
			}
		}
		Return d
	}

	iWeb_Checked(pdsp,obj,chkd=1,sIndex=-1,frm="")
	{
		If !pWin := frm ? iWeb_DomWin(pdsp,frm) : iWeb_domWin(pdsp)
			return False
		rObj:=pWin.document.all[obj]
		sIndex > -1 ? (rObj.item[sIndex].checked:=chkd) : (rObj.checked:=chkd)
		c :=(sIndex > -1 ? (rObj.item[sIndex].checked) : (rObj.checked)) ? True : False
		iWeb_FireEvents(rObj)
		Return	c
	}

	iWeb_selectOption(pdsp,sName,selected,method="selectedIndex",frm="")
	{
		If !pWin := frm ? iWeb_DomWin(pdsp,frm) : iWeb_domWin(pdsp)
			return False
		dObj:=pWin.document.all[sName]
		dObj[method]:=selected
		iWeb_FireEvents(dObj)
		Return True	
	}

	iWeb_getTagLen(pdsp,tag,frm="")
	{ 

		if !pWin := frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		return pWin.document.all.tags[tag].length

	}

	iWeb_getTagObj(pdsp,tag,itm,type="innerText",frm="")
	{ 

		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		return pWin.document.all.tags[tag].item[itm][type] 

	}

	iWeb_getTblLen(pdsp,t,r=-1,frm="")
	{ 

		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		tObj:=pWin.document.all.tags["table"].item[t] 
		return r<0 ? tObj.rows.length : tObj.rows[r].cells.length 

	}

	iWeb_getTblObj(pdsp,t,r=-1,c=-1,type="innerText",frm="")
	{ 

		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		tObj:=pWin.document.all.tags["table"].item[t] 
		return (r>-1 && c<0) ? tObj.rows[r][type] 
		 : (r>-1 && c>-1) ? tObj.rows[r].cells[c][type] 
		 : tObj[type] 

	}

	iWeb_FireEvents(ele)
	{
		COM_Error(0)
		COM_Invoke(ele,"onfocus")
		COM_Invoke(ele,"onblur")
		COM_Invoke(ele,"onchange")
		COM_Invoke(ele,"onclick")
		COM_Invoke(ele,"onkeyup")
		COM_Error(1)
	
	}

;~~~~~ functions that click ~~~~~

	iWeb_clickDomObj(pdsp,obj,frm="")
	{

		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		itm:=pWin.document.all[obj].click
		iWeb_FireEvents(itm)
		Return	True
	}
	iWeb_clickText(pdsp,t,frm="")
	{

		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False 
		Loop % pWin.document.links.length {
			itm:=pWin.document.links.item[A_Index-1]
			If InStr(itm.innertext,t) {
				v:=itm.click
				iWeb_FireEvents(itm)
				Break
			}
		}	
		Return True
	}
	iWeb_clickHref(pdsp,t,frm="")
	{
		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False
		Loop % pWin.document.links.length {
			itm:=pWin.document.links.item[A_Index-1]
			If InStr(itm.href,t) {
				v:=itm.click
				iWeb_FireEvents(itm)
				Break
			}
		}	
		Return True
	}
	iWeb_clickValue(pdsp,t,frm="")
	{
		if !pWin:=frm ? iWeb_domWin(pdsp,frm) : iWeb_domWin(pdsp) 
			return False
		Loop % pWin.document.all.length {
			itm:=pWin.document.all.item[A_Index-1]
			If iWeb_inpt(itm) ? InStr(itm.value,t) : 0
			{
					v:=itm.click
					iWeb_FireEvents(itm)
					Break
			}	
		}
		Return True
	}

;~~~~~ Functions used to interact with scripts embeded in a web page ~~~~~

;~ 	insert and execute a javascript statement into an exisiting document window
	iWeb_execScript(pwb,js,frm="")
	{
		if !pWin := frm ? iWeb_DomWin(pwb,frm) : iWeb_DomWin(pwb)
			return False
		return pWin.execScript:=js
	}

;~ 	retreive a global variable value from a page
	iWeb_getVar(pwb,var,frm="")
	{
		if !pWin := frm ? iWeb_DomWin(pwb,frm) : iWeb_DomWin(pwb)
			return False
		return pWin.var
	}
	
	;~ 	this helper function is really designed to return only 
	;~ 	useable un formated text that can be used within javascript
	iWeb_escape_text(txt)
	{
		
		StringReplace,txt,txt,',\',ALL
		StringReplace,txt,txt,"",\"",ALL
		;~ StringReplace,txt,txt,`.`.,`.,ALL
		StringReplace,txt,txt,`r,%a_space%,ALL
		StringReplace,txt,txt,`n,%a_space%,ALL
		StringReplace,txt,txt,`n`r,%a_space%,ALL
		StringReplace,txt,txt,%a_space%%a_space%,%a_space%,ALL
		return txt	
	}
;~ 	simply stripts html tags from a string
	iWeb_striphtml(HTML)
	{
;~ 		thanks lazlo http://www.autohotkey.com/forum/viewtopic.php?p=71935#71935
		Loop Parse, HTML, <>
			If (A_Index & 1) 
				noHTML .= A_LoopField
		Return noHTML
	}

	;~ takes an html fragment and creates a DOM document from a string

	iWeb_Txt2Doc(t)
	{
		If	doc := COM_CreateObject("{25336920-03F9-11CF-8FD0-00AA00686F13}") 
			COM_Invoke(doc, "write", t),COM_Invoke(doc, "close") 
		Return doc
	}

;~ Sets a window and tab as active by the page title

	iWeb_Activate(sTitle) 
	{ 
		; thanks Sean 
		; http://www.autohotkey.com/forum/viewtopic.php?p=231093#231093 
		DllCall("LoadLibrary", "str", "oleacc.dll") 
		DetectHiddenWindows, On 
		WinActivate,% "ahk_id " HWND
		WinWaitActive,% "ahk_id " HWND,,5
		ControlGet, hTabBand, hWnd,, TabBandClass1, ahk_class IEFrame
		ControlGet, hTabUI  , hWnd,, DirectUIHWND1, ahk_id %hTabBand% 
		If   hTabUI && DllCall("oleacc\AccessibleObjectFromWindow", "Uint", hTabUI, "Uint",-4, "Uint", COM_GUID4String(IID_IAccessible,"{618736E0-3C3D-11CF-810C-00AA00389B71}"), "UintP", pacc)=0 
		{ 
			Loop, %   pacc.accChildCount 
				If   paccChild:=pacc.accChild[A_Index] 
					If   paccChild.accRole[0] = 0x3C 
					{ 
						paccTab:=paccChild 
						Break 
					} 
		} 
		If   pacc:=paccTab 
		{ 
			Loop, %   pacc.accChildCount 
				If   paccChild:=pacc.accChild[A_Index] 
					If   paccChild.accName[0] = sTitle   
					{ 
						paccChild.accDoDefaultAction[0]
						Break 
					} 
		}  
		WinActivate,% sTitle
	} 
