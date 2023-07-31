Hostname() {
    local
    RegRead hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
    return hostname
}
