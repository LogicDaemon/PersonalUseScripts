﻿;Скрипт сортирует файлы с рабочего стола по стандартным папкам на основе расширений

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

DestDirs := [ GetKnownFolder("Music")
	    , GetKnownFolder("Videos")
	    , GetKnownFolder("Pictures") ]

For i,dir in DestDirs {
    If (DestDirs[i] && !InStr(FileExist(dir), "D"))
	DestDirs[i]:=""
}

SortList := {"wav" : 1, "aif" : 1, "aiff" : 1, "iff" : 1, "svx" : 1, "snd" : 1, "au" : 1, "voc" : 1, "mka" : 1, "cue" : 1, "apl" : 1, "ogg" : 1, "mpc" : 1, "mp+" : 1, "mpp" : 1, "mp3" : 1, "mp2" : 1, "mp4" : 1, "m4a" : 1, "aac" : 1, "flac" : 1, "fla" : 1, "ape" : 1, "mac" : 1, "wv" : 1, "shn" : 1, "ofr" : 1, "ofs" : 1, "pac" : 1, "tta" : 1, "spx" : 1, "wma" : 1, "ac3" : 1, "xm" : 1, "it" : 1, "s3m" : 1, "mod" : 1, "mtm" : 1, "umx" : 1, "mdz" : 1, "s3z" : 1, "itz" : 1, "xmz" : 1, "tfm" : 1, "spc" : 1, "psf" : 1, "minipsf" : 1, "psf2" : 1, "minipsf2" : 1, "nsf" : 1, "kss" : 1, "gbr" : 1, "gbs" : 1, "hes" : 1, "pce" : 1, "ay" : 1, "cpc" : 1, "nsfe" : 1, "sid" : 1, "xa" : 1, "cda" : 1
	, "asf" : 2, "avi" : 2, "dat" : 2, "divx" : 2, "m1v" : 2, "m2v" : 2, "mkv" : 2, "mov" : 2, "mp4" : 2, "mpe" : 2, "mpeg" : 2, "mpg" : 2, "mpv" : 2, "ogm" : 2, "qt" : 2, "rm" : 2, "rv" : 2, "vob" : 2, "wm" : 2, "wmv" : 2, "flv" : 2
	, "bmp" : 3, "jpg" : 3, "jpeg" : 3, "gif" : 3, "ico" : 3, "pcx" : 3, "rle" : 3, "tga" : 3, "jif" : 3, "png" : 3, "dib" : 3, "tif" : 3
	, "emf" : 3, "wmf" : 3, "svg" : 3, "cdr" : 3, "dot" : 3}

source=%1%
If (!source || !InStr(FileExist(source), "D"))
    Source := A_Desktop

Loop Files, %Source%\*.*, R
{
    If (SortList.HasKey(A_LoopFileExt)) {
	MsgBox % A_LoopFileFullPath " → " SortList[A_LoopFileExt]
    }
}

GetKnownFolder(FolderName) { ;http://www.autohotkey.com/forum/viewtopic.php?t=68194 
    If !RegExMatch(folderdata(),"im`a)^" . foldername . ".+$",line) 
	return 0, ErrorLevel := -2 ;FolderName not found 
    StringSplit,data,line,`, 
    VarSetCapacity(mypath,(A_IsUnicode ? 2 : 1)*1025) 
    
    If A_OSVersion in WIN_2003,WIN_XP,WIN_2000
    {
	If !data3 
	    return 0, ErrorLevel := -1  ;No corresponding CSILD value 
	r := DllCall("Shell32\SHGetFolderPath", "int", 0 , "uint", data3 , "int", 0 , "uint", 0 , "str" , mypath) 
	return (r or ErrorLevel) ? 0 : mypath 
    } Else {
	If !data2
	    return 0, ErrorLevel := -1  ;No corresponding FOLDERID value 
	SetGUID(rfid, data2)
	r := DllCall("Shell32\SHGetKnownFolderPath", "UInt", &rfid, "UInt", 0, "UInt", 0, "UIntP", mypath)
	return (r or ErrorLevel) ? 0 : StrGet(mypath,,"UTF-16") 
    }
} 

SetGUID(ByRef GUID, String) { 
    VarSetCapacity(GUID, 16, 0) 
    StringReplace,String,String,-,,All 
    NumPut("0x" . SubStr(String, 2,  8), GUID, 0,  "UInt")   ; DWORD Data1 
    NumPut("0x" . SubStr(String, 10, 4), GUID, 4,  "UShort") ; WORD  Data2 
    NumPut("0x" . SubStr(String, 14, 4), GUID, 6,  "UShort") ; WORD  Data3 
    Loop, 8 
	NumPut("0x" . SubStr(String, 16+(A_Index*2), 2), GUID, 7+A_Index,  "UChar")  ; BYTE  Data4[A_Index] 
} 

folderdata() { 
folderdata =  ;structure is Name,GUID,CSIDL 
( 
AdminTools,{724EF170-A42D-4FEF-9F26-B60E846FBA4F},48 
CDBurning,{9E52AB10-F80D-49DF-ACB8-4330F5687855},59 
CommonAdminTools,{D0384E7D-BAC3-4797-8F14-CBA229B392B5},47 
CommonOEMLinks,{C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D},58 
CommonPrograms,{0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8},23 
CommonStartMenu,{A4115719-D62E-491D-AA7C-E74B8BE3B067},22 
CommonStartup,{82A5EA35-D9CD-47C5-9629-E15D2F714E6E},24 
CommonTemplates,{B94237E7-57AC-4347-9151-B08C6C32D1F7},45 
Contacts,{56784854-C6CB-462b-8169-88E350ACB882}, 
Cookies,{2B0F765D-C0E9-4171-908E-08A611B84FF6},33 
Desktop,{B4BFCC3A-DB2C-424C-B029-7FE99A87C641},0 
DeviceMetadataStore,{5CE4A5E9-E4EB-479D-B89F-130C02886155}, 
DocumentsLibrary,{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}, 
Downloads,{374DE290-123F-4565-9164-39C4925E467B}, 
Favorites,{1777F761-68AD-4D8A-87BD-30B759FA33DD},6 
Fonts,{FD228CB7-AE11-4AE3-864C-16F3910AB8FE},20 
GameTasks,{054FAE61-4DD8-4787-80B6-090220C4B700}, 
History,{D9DC8A3B-B784-432E-A781-5A1130A75963},34 
ImplicitAppShortcuts,{BCB5256F-79F6-4CEE-B725-DC34E402FD46}, 
InternetCache,{352481E8-33BE-4251-BA85-6007CAEDCF9D},32 
Libraries,{1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}, 
Links,{bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}, 
LocalAppData,{F1B32785-6FBA-4FCF-9D55-7B8E7F157091},28 
LocalAppDataLow,{A520A1A4-1780-4FF6-BD18-167343C5AF16}, 
LocalizedResourcesDir,{2A00375E-224C-49DE-B8D1-440DF7EF3DDC},57 
Music,{4BD8D571-6D19-48D3-BE97-422220080E43}, 
MusicLibrary,{2112AB0A-C86A-4FFE-A368-0DE96E47012E}, 
NetHood,{C5ABBF53-E17F-4121-8900-86626FC2C973},19 
OriginalImages,{2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39}, 
PhotoAlbums,{69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}, 
Pictures,{33E28130-4E1E-4676-835A-98395C3BC3BB},39 
PicturesLibrary,{A990AE9F-A03B-4E80-94BC-9912D7504104}, 
Playlists,{DE92C1C7-837F-4F69-A3BB-86E631204A23}, 
PrintHood,{9274BD8D-CFD1-41C3-B35E-B13F55A758F4},27 
Profile,{5E6C858F-0E22-4760-9AFE-EA3317B67173},40 
ProgramData,{62AB5D82-FDC1-4DC3-A9DD-070D1D495D97},35 
ProgramFiles,{905e63b6-c1bf-494e-b29c-65b732d3d21a},38 
ProgramFilesCommon,{F7F1ED05-9F6D-47A2-AAAE-29D317C6F066},43 
ProgramFilesCommonX64,{6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}, 
ProgramFilesCommonX86,{DE974D24-D9C6-4D3E-BF91-F4455120B917},44 
ProgramFilesX64,{6D809377-6AF0-444b-8957-A3773F02200E}, 
ProgramFilesX86,{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E},42 
Programs,{A77F5D77-2E2B-44C3-A6A2-ABA601054A51},2 
Public,{DFDF76A2-C82A-4D63-906A-5644AC457385}, 
PublicDesktop,{C4AA340D-F20F-4863-AFEF-F87EF2E6BA25},25 
PublicDocuments,{ED4824AF-DCE4-45A8-81E2-FC7965083634},46 
PublicDownloads,{3D644C9B-1FB8-4f30-9B45-F670235F79C0}, 
PublicGameTasks,{DEBF2536-E1A8-4c59-B6A2-414586476AEA}, 
PublicLibraries,{48DAF80B-E6CF-4F4E-B800-0E69D84EE384}, 
PublicMusic,{3214FAB5-9757-4298-BB61-92A9DEAA44FF},53 
PublicPictures,{B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5},54 
PublicRingtones,{E555AB60-153B-4D17-9F04-A5FE99FC15EC}, 
PublicVideos,{2400183A-6185-49FB-A2D8-4A392A602BA3},55 
QuickLaunch,{52a4f021-7b75-48a9-9f6b-4b87a210bc8f}, 
Recent,{AE50C081-EBD2-438A-8655-8A092E34987A},8 
RecordedTVLibrary,{1A6FDBA2-F42D-4358-A798-B74D745926C5}, 
ResourceDir,{8AD10C31-2ADB-4296-A8F7-E4701232C972},56 
Ringtones,{C870044B-F49E-4126-A9C3-B52A1FF411E8}, 
RoamingAppData,{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D},26 
SampleMusic,{B250C668-F57D-4EE1-A63C-290EE7D1AA1F}, 
SamplePictures,{C4900540-2379-4C75-844B-64E6FAF8716B}, 
SamplePlaylists,{15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}, 
SampleVideos,{859EAD94-2E85-48AD-A71A-0969CB56A6CD}, 
SavedGames,{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}, 
SavedSearches,{7d1d3a04-debb-4115-95cf-2f29da2920da}, 
SendTo,{8983036C-27C0-404B-8F08-102D10DCFD74},9 
SidebarDefaultParts,{7B396E54-9EC5-4300-BE0A-2482EBAE1A26}, 
SidebarParts,{A75D362E-50FC-4fb7-AC2C-A8BEAA314493}, 
StartMenu,{625B53C3-AB48-4EC1-BA1F-A1EF4146FC19},11 
Startup,{B97D20BB-F46A-4C97-BA10-5E3608430854},7 
System,{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7},37 
SystemX86,{D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27},41 
Templates,{A63293E8-664E-48DB-A079-DF759E0509F7},21 
UserPinned,{9E3995AB-1F9C-4F13-B827-48B24B6C7174}, 
UserProfiles,{0762D272-C50A-4BB0-A382-697DCD729B80}, 
UserProgramFiles,{5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}, 
UserProgramFilesCommon,{BCBD3057-CA5C-4622-B42D-BC56DB0AE516}, 
Videos,{18989B1D-99B5-455B-841C-AB7C74E4DDFC}, 
VideosLibrary,{491E922F-5643-4AF4-A7EB-4E7A138D8174}, 
Windows,{F38BF404-1D43-42F2-9305-67DE0B28FC23},36 
ALTSTARTUP,,29 
COMMON_ALTSTARTUP,,30 
COMMON_FAVORITES,,31 
COMPUTERSNEARME,,61 
DESKTOPDIRECTORY,,16 
PERSONAL,,5 
) 
return folderdata 
}
