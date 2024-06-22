; https://www.autohotkey.com/boards/viewtopic.php?style=7&t=86940
; showlink.ahk <path>
; reveals all locations hardlinked to path
; path must be complete
; does not show target location; shows first location in active explorer window
; opens new explorer window for all other locations
; has nothing to do if the target location is the only location

; take arguments
try targetpath := A_Args.RemoveAt(1)
catch
	MsgBox("No target specified") && ExitApp()

if (SubStr(targetpath, 2, 2) != ":\") ; gotcha: 2 is the length, not the end
	MsgBox("Target path is not complete") && ExitApp()

explorer := GetActiveExplorer()
for path in ListLinks(targetpath)
	(path != targetpath) && explorer := ShowPath(path, explorer)

; ---------------------------------------------------------------------------- ;

ShowPath(path, explorer)
{
	if (explorer)
	{
		; in an existing explorer window, navigate to and select the specified file
		; regex will never fail
		explorer.Navigate(RegExMatch(path, "(.*)\\.*", match) ? match[1] : MsgBox("Regex failure"))
		; it takes some time to navigate and start seeing files
		
		; https www.mrexcel.com /board/threads/select-a-file-in-file-explorer-from-a-list-of-files-in-excel-in-the-same-fe-window.1084715/  Broken Link for safety
		; https://stackoverflow.com/questions/2518257/get-the-selected-file-in-an-explorer-window
		; event-based approach didn't work out, let's spin around in circles until we get it
		success := false
		stopAt := A_TickCount + 3000
		loop
			try explorer.Document.SelectItem(path, 5) || success := true
			catch
				Sleep(10)
		until success || A_TickCount > stopAt
	} else {
		; open a new explorer window with the path selected
		; gotcha: the quotes must start after the comma!
		Run("explorer.exe /select,`"" path "`"")
	}
}

; get currently active explorer window or nothing
; https://autohotkey.com/board/topic/102127-navigating-explorer-directories/
GetActiveExplorer()
{
	WinHWND := WinActive("A") ; Active window
	for Item in ComObjCreate("Shell.Application").Windows
		if (Item.HWND == WinHWND)
			return Item ; Return active window object
}

; enumerate all locations of file
; prepends drive letter before the output paths to make them whole :)
; todo: take advantage of buflen being set to the required length
; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilenamew
; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilenamew
ListLinks(path)
{
	static ERROR_MORE_DATA := 234
	static MAX_PATH := 260
	
	root := SubStr(path, 1, 2)
	paths := []
	
	buflen := MAX_PATH
	VarSetStrCapacity(linkname, buflen)
	handle := DllCall("FindFirstFileNameW",
		"WStr", path,
		"UInt", 0,
		"UInt*", buflen,
		"WStr", linkname)
	
	if (A_LastError == ERROR_MORE_DATA)
		throw "ListLinks: ERROR_MORE_DATA, 260 was not enough..."
	if (handle == 0xffffffff)
		throw "ListLinks: FindFirstFileNameW failed"
	
	try
	{
		Loop
		{
			paths.Push(root linkname)
			
			buflen := MAX_PATH
			VarSetStrCapacity(linkname, buflen)
			more := DllCall("FindNextFileNameW",
			"UInt", handle,
			"UInt*", buflen,
			"WStr", linkname)
		} until (!more)
		
		if (A_LastError == ERROR_MORE_DATA)
			throw "ListLinks: ERROR_MORE_DATA, 260 was not enough..."
	} finally
		DllCall("FindClose", "UInt", handle)
	
	return paths
}
