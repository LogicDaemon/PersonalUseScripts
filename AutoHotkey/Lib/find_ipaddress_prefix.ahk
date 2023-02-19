#NoEnv

Loop 4
{
    For i, prefix in A_Args
    {
        If (SubStr(A_IPAddress%A_Index%, 1, StrLen(prefix)) == prefix) {
            FileAppend % A_IPAddress%A_Index%, *, CP1
            Exit 0
        }
    }
}
Exit 1
