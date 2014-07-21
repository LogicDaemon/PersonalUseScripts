@REM <meta http-equiv="Content-Type" content="text/batch; charset=cp866">
@Echo Off
SetLocal
Set OutputDir=%CD%

CD /D %SystemDrive%\SysUtils
Call %OutputDir%\z_prepare_pack.cmd SysUtils

CD /D %SystemDrive%\Arc\7-Zip
Call %OutputDir%\z_prepare_pack.cmd 7-Zip

CD /D %SystemDrive%\Arc\WinRAR
Call %OutputDir%\z_prepare_pack.cmd WinRAR

CD /D %ProgramFiles%\Far
Call %OutputDir%\z_prepare_pack.cmd FAR

CD /D %ProgramFiles%\IrfanView
Call %OutputDir%\z_prepare_pack.cmd IrfanView

CD /D %ProgramFiles%\Total Commander
Call %OutputDir%\z_prepare_pack.cmd TotalCommander

CD /D %ProgramFiles%\EditPlus 2
Call %OutputDir%\z_prepare_pack.cmd EditPlus2

CD /D D:\Program Files\TreePad
Call %OutputDir%\z_prepare_pack.cmd TreePad

CD /D D:\Program Files\WinImage
Call %OutputDir%\z_prepare_pack.cmd WinImage

CD /D D:\Program Files\foobar2000
Call %OutputDir%\z_prepare_pack.cmd Foobar2000

CD /D D:\Program Files\CDEx
Call %OutputDir%\z_prepare_pack.cmd CDex

CD /D D:\Program Files\Crystal Player
Call %OutputDir%\z_prepare_pack.cmd CrystalPlayer

CD /D D:\Program Files\DriveKey
Call %OutputDir%\z_prepare_pack.cmd HPDriveKey

CD /D D:\Program Files\Dude
Call %OutputDir%\z_prepare_pack.cmd NetworkDude

CD /D D:\Program Files\Flash Memory Toolkit
Call %OutputDir%\z_prepare_pack.cmd FlashMemoryToolkit

CD /D D:\Program Files\FreeMind
Call %OutputDir%\z_prepare_pack.cmd FreeMind

CD /D D:\Program Files\HDTune
Call %OutputDir%\z_prepare_pack.cmd HDTune

CD /D D:\Program Files\IP-Tools
Call %OutputDir%\z_prepare_pack.cmd IPTools

CD /D D:\Program Files\KeyNote
Call %OutputDir%\z_prepare_pack.cmd KeyNote

CD /D D:\Program Files\miranda.en
Call %OutputDir%\z_prepare_pack.cmd miranda_en_alpha

CD /D D:\Program Files\RegCleaner
Call %OutputDir%\z_prepare_pack.cmd RegCleaner

CD /D D:\Program Files\RegCompact
Call %OutputDir%\z_prepare_pack.cmd RegCompact

CD /D D:\Program Files\SciTE
Call %OutputDir%\z_prepare_pack.cmd SciTE

CD /D D:\Program Files\TreePad
Call %OutputDir%\z_prepare_pack.cmd TreePad

CD /D D:\Program Files\TrueCrypt
Call %OutputDir%\z_prepare_pack.cmd

CD /D D:\Program Files\UltraISO
Call %OutputDir%\z_prepare_pack.cmd

Call %OutputDir%\z_prepare_pack.cmd D:\Program Files\WinImage \\Srv0\profiles$\Share\Miranda

CD /D D:\bb4win
Call %OutputDir%\z_prepare_pack.cmd 

Call %OutputDir%\z_prepare_pack_target.cmd D:\Program Files\Atomic.exe

Call %OutputDir%\z_prepare_pack_dir.cmd 
