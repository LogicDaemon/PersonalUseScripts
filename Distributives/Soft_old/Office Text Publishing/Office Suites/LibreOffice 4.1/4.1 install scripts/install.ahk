#NoEnv
#SingleInstance ignore

EnvGet RunInteractiveInstalls,RunInteractiveInstalls
if not A_IsAdmin
{
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

DistributiveMask=%A_ScriptDir%\LibreOffice_*_Win_x86.msi
HelpDistrMask=%A_ScriptDir%\LibreOffice_*_Win_x86_helppack_ru.msi

EnvGet LogPath,logmsi

;before 2013-04-05
;RemoveLangpacks=gm_Langpack_r_af`,gm_Langpack_r_sq`,gm_Langpack_r_ar`,gm_Langpack_r_as`,gm_Langpack_r_ast`,gm_Langpack_r_eu`,gm_Langpack_r_be`,gm_Langpack_r_bn`,gm_Langpack_r_brx`,gm_Langpack_r_bs`,gm_Langpack_r_br`,gm_Langpack_r_bg`,gm_Langpack_r_my`,gm_Langpack_r_ca`,gm_Langpack_r_ca_XV`,gm_Langpack_r_zh_CN`,gm_Langpack_r_zh_TW`,gm_Langpack_r_hr`,gm_Langpack_r_cs`,gm_Langpack_r_da`,gm_Langpack_r_dgo`,gm_Langpack_r_nl`,gm_Langpack_r_dz`,gm_Langpack_r_en_US`,gm_Langpack_r_en_ZA`,gm_Langpack_r_eo`,gm_Langpack_r_et`,gm_Langpack_r_fa`,gm_Langpack_r_fi`,gm_Langpack_r_fr`,gm_Langpack_r_gl`,gm_Langpack_r_ka`,gm_Langpack_r_de`,gm_Langpack_r_el`,gm_Langpack_r_gu`,gm_Langpack_r_he`,gm_Langpack_r_hi`,gm_Langpack_r_hu`,gm_Langpack_r_is`,gm_Langpack_r_id`,gm_Langpack_r_ga`,gm_Langpack_r_it`,gm_Langpack_r_ja`,gm_Langpack_r_kn`,gm_Langpack_r_ks`,gm_Langpack_r_kk`,gm_Langpack_r_km`,gm_Langpack_r_rw`,gm_Langpack_r_kok`,gm_Langpack_r_ko`,gm_Langpack_r_ku`,gm_Langpack_r_lo`,gm_Langpack_r_lv`,gm_Langpack_r_lt`,gm_Langpack_r_lb`,gm_Langpack_r_mk`,gm_Langpack_r_mai`,gm_Langpack_r_ml`,gm_Langpack_r_mni`,gm_Langpack_r_mr`,gm_Langpack_r_mn`,gm_Langpack_r_nr`,gm_Langpack_r_ne`,gm_Langpack_r_nso`,gm_Langpack_r_nb`,gm_Langpack_r_nn`,gm_Langpack_r_oc`,gm_Langpack_r_or`,gm_Langpack_r_om`,gm_Langpack_r_pl`,gm_Langpack_r_pt`,gm_Langpack_r_pt_BR`,gm_Langpack_r_pa_IN`,gm_Langpack_r_ro`,gm_Langpack_r_sa_IN`,gm_Langpack_r_sat`,gm_Langpack_r_gd`,gm_Langpack_r_sr`,gm_Langpack_r_sh`,gm_Langpack_r_sd`,gm_Langpack_r_si`,gm_Langpack_r_sk`,gm_Langpack_r_sl`,gm_Langpack_r_st`,gm_Langpack_r_es`,gm_Langpack_r_sw_TZ`,gm_Langpack_r_ss`,gm_Langpack_r_sv`,gm_Langpack_r_tg`,gm_Langpack_r_ta`,gm_Langpack_r_tt`,gm_Langpack_r_te`,gm_Langpack_r_th`,gm_Langpack_r_bo`,gm_Langpack_r_ts`,gm_Langpack_r_tn`,gm_Langpack_r_tr`,gm_Langpack_r_uk`,gm_Langpack_r_ug`,gm_Langpack_r_uz`,gm_Langpack_r_ve`,gm_Langpack_r_vi`,gm_Langpack_r_cy`,gm_Langpack_r_xh`,gm_Langpack_r_zu
;RemoveDictionaries=gm_r_ex_Dictionary_Af`,gm_r_ex_Dictionary_An`,gm_r_ex_Dictionary_Ar`,gm_r_ex_Dictionary_Be`,gm_r_ex_Dictionary_Bg`,gm_r_ex_Dictionary_Bn`,gm_r_ex_Dictionary_Br`,gm_r_ex_Dictionary_Pt`,gm_r_ex_Dictionary_Pt_Pt`,gm_r_ex_Dictionary_Ca`,gm_r_ex_Dictionary_Cs`,gm_r_ex_Dictionary_Da`,gm_r_ex_Dictionary_Nl`,gm_r_ex_Dictionary_Et`,gm_r_ex_Dictionary_Fr`,gm_r_ex_Dictionary_Gd`,gm_r_ex_Dictionary_Gl`,gm_r_ex_Dictionary_Gu`,gm_r_ex_Dictionary_De`,gm_r_ex_Dictionary_He`,gm_r_ex_Dictionary_Hi`,gm_r_ex_Dictionary_Hu`,gm_r_ex_Dictionary_Hr`,gm_r_ex_Dictionary_It`,gm_r_ex_Dictionary_Ku_Tr`,gm_r_ex_Dictionary_Lt`,gm_r_ex_Dictionary_Lv`,gm_r_ex_Dictionary_Ne`,gm_r_ex_Dictionary_No`,gm_r_ex_Dictionary_Oc`,gm_r_ex_Dictionary_Pl`,gm_r_ex_Dictionary_Ro`,gm_r_ex_Dictionary_Si`,gm_r_ex_Dictionary_Sr`,gm_r_ex_Dictionary_Sk`,gm_r_ex_Dictionary_Sl`,gm_r_ex_Dictionary_El`,gm_r_ex_Dictionary_Es`,gm_r_ex_Dictionary_Sv`,gm_r_ex_Dictionary_Te`,gm_r_ex_Dictionary_Th`,gm_r_ex_Dictionary_Uk`,gm_r_ex_Dictionary_Vi`,gm_r_ex_Dictionary_Zu
;RemoveOtherComponents=gm_o_Xsltfiltersamples`,gm_o_Pyuno`,gm_o_Quickstart`,gm_o_Onlineupdate`,gm_o_Extensions_Script_Provider_For_Python`,gm_o_Extensions_Script_Provider_For_Beanshell

FileRead RemoveLangpacks,%A_ScriptDir%\remove_langpacks.txt
FileRead RemoveDictionaries,%A_ScriptDir%\remove_langpacks.txt
FileRead RemoveOtherComponents,%A_ScriptDir%\remove_OtherComponents.txt

Remove=%RemoveOtherComponents%`,%RemoveLangpacks%
;,%RemoveDictionaries%

; even    QuietInstall := /qb is interactive!!!!, so the only option is /qn
QuietInstall = /qn

;Searching distributives
Loop %DistributiveMask%
    If A_LoopFileFullPath > %Distributive% ; * is less than any digit, so mask will go away first
	Distributive:=A_LoopFileFullPath
If Not Distributive
    CheckError(-1, "Not found distributive with mask """ . DistributiveMask . """, workdir: """ . A_WorkingDir . """")

Loop %HelpDistrMask%
    If A_LoopFileFullPath > %HelpDistr% ; * is less than any digit, so mask will go away first
	HelpDistr=%A_LoopFileFullPath%
If Not HelpDistr
    CheckError(-1, "Not found helpfile distributive with mask """ . HelpDistrMask . """, workdir: """ . A_WorkingDir . """")

;Installing
ErrorsOccured := ErrorsOccured || InstallMSI(Distributive, QuietInstall . " COMPANYNAME=""Цифроград-Ставрополь`, ООО"" ISCHECKFORPRODUCTUPDATE=0 REGISTER_ALL_MSO_TYPES=1 ADDLOCAL=ALL REMOVE=" . Remove . " AgreeToLicense=Yes")

If (!ErrorsOccured) {
    ErrorsOccured := ErrorsOccured || InstallMSI(HelpDistr, QuietInstall)
    RunWait "%A_AhkPath%" Install_Extensions.ahk, %A_ScriptDir%, Min UseErrorLevel
    ErrorsOccured := ErrorsOccured || ErrorLevel

    EnvGet SetDefaults,SetDefaults
    If SetDefaults=0
	return

    RunWait %comspec% /C "%A_ScriptDir%\SetDefaults.cmd",%A_ScriptDir%,Min UseErrorLevel
    ErrorsOccured := ErrorsOccured || ErrorLevel
}

Exit ErrorsOccured

InstallMSI(MSIFileFullPath, params){
    Global LogPath
    
    ReturnErrValue=
    
    SplitPath MSIFileFullPath, MSIFileName
    If Not LogPath
	LogPath=%A_TEMP%\%MSIFileName%.log
    RunWait msiexec.exe /i "%MSIFileFullPath%" %params% /norestart /l+* "%LogPath%",, UseErrorLevel
    
    return CheckError(ErrorLevel, MSIFileName)
    
    return %ReturnErrValue%
}

CheckError(ReturnErrValue, Description) {
    Global RunInteractiveInstalls,LogPath
    If ReturnErrValue!=0
    {
	FileAppend Error %ReturnErrValue% installing %Description%`nLog written to %LogPath%, *
	If RunInteractiveInstalls!=0
	    MsgBox 48, LibreOffice Installing error, ErrorLevel: %ReturnErrValue%`n%Description%, 30
    } else {
	FileAppend Finished installing %Description%`n, *
    }
    return ReturnErrValue
}
