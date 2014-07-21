#NoEnv

prefix = 10.

Loop
{
    Loop 4
    {
        If (SubStr(A_IPAddress%A_Index%, 1, StrLen(prefix)) == prefix) {
            FileAppend % A_IPAddress%A_Index%, *, CP1
            Exit 0
        }
    }
    
    Sleep 3000
}
