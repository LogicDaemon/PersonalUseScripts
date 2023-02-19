; by jNizM https://www.autohotkey.com/boards/viewtopic.php?p=92604&sid=2d7c28698c4dde0d498cfa85f4a86485#p92604
ReverseLookup(ipaddr)
{
    VarSetCapacity(WSADATA, 394 + (A_PtrSize - 2) + A_PtrSize, 0)
    if (DllCall("ws2_32\WSAStartup", "ushort", 0x0202, "ptr", &WSADATA) != 0)
        return "WSAStartup failed", DllCall("ws2_32\WSACleanup")

    inaddr := DllCall("ws2_32\inet_addr", "astr", ipaddr, "uint")
    if !(inaddr) || (inaddr = 0xFFFFFFFF)
        return "inet_addr failed", DllCall("ws2_32\WSACleanup")

    size := VarSetCapacity(sockaddr, 16, 0), NumPut(2, sockaddr, 0, "short") && NumPut(inaddr, sockaddr, 4, "uint")
    VarSetCapacity(hostname, 1025 * (A_IsUnicode ? 2 : 1))
    if (DllCall("ws2_32\getnameinfo", "ptr", &sockaddr, "int", size, "ptr", &hostname, "uint", 1025, "ptr", 0, "uint", 32, "int", 0))
        return "getnameinfo failed with error: " DllCall("ws2_32\WSAGetLastError"), DllCall("ws2_32\WSACleanup")
    return StrGet(&hostname+0, 1025, "cp0"), DllCall("ws2_32\WSACleanup")
}
