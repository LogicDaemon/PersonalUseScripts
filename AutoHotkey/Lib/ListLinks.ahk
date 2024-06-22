; by Saiapatsu
; https://www.autohotkey.com/boards/viewtopic.php?style=7&t=86940
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
