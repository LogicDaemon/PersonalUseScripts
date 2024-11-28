;0BSD (https://opensource.org/license/0bsd) / public domain by LogicDaemon <https://www.logicdaemon.ru/>
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
