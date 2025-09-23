;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>

GetURL(ByRef URL, headers:="", tries := 3, delay := 3000) {
    While (!XMLHTTP_Request("GET", URL,, resp, headers))
	If (A_Index > tries)
	    Throw Exception("Error downloading URL", A_ThisFunc, resp.status)
	Else
	    sleep delay
    
    return resp
}

#include %A_LineFile%\..\XMLHTTP_Request.ahk
