;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
#NoEnv

; compare versions by components
VersionAtLeast(verTest, verMin) {
    return VersionCompare(verTest, verMin, true)
}
