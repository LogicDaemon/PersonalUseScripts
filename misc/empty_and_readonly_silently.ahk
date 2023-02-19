;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

Loop %0%
{
    arg := %A_Index%
    Loop %arg%
    {
	FileRecycle %A_LoopFileFullPath%
    ;    FileDelete
	FileAppend,,%A_LoopFileFullPath%
	FileSetAttrib +R, %A_LoopFileFullPath%
    }
}
