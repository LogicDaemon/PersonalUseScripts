;https://autohotkey.com/board/topic/41310-safelyremoveums-safely-remove-usb-mass-storage-drives/
SafelyRemoveUMS( DrivePath, Retry=0 ) { ; v1.01 by SKAN,   CD:01-Sep-2012 / LM:09-Sep-2014
;      AutoHotkey Forum Topic :  http://www.autohotkey.com/community/viewtopic.php?t=44873

 hVol  := DllCall( "CreateFile"
                 , Str,  "\\.\" . ( Drive  := SubStr( DrivePath, 1, 1 ) . ":" )
                 , UInt, 0 
                 , UInt, 0 
                 , UInt, 0
                 , UInt, 0x3
                 , UInt, 0x0
                 , UInt, 0  )


 If ( hvol < 1 )
    Return 0, ErrorLevel := 1             ; Unable to access volume!


 VarSetCapacity( GenBuf, 2080, 0 )        ; General, all-purpose buffer


 pSTORAGE_PROPERTY_QUERY    := &GenBuf                       ;  MSDN  http://bit.ly/SvILmx
 pSTORAGE_DESCRIPTOR_HEADER := &GenBuf + 12                  ;  MSDN  http://bit.ly/O8UNiH
 NumPut( StorageDeviceProperty := 0, pSTORAGE_PROPERTY_QUERY + 0 )


 DllCall( "DeviceIoControl"
        , UInt, hVol
        , UInt, 0x2D1400   ; IOCTL_STORAGE_QUERY_PROPERTY    ;  MSDN: http://bit.ly/OdLos0
        , UInt, pSTORAGE_PROPERTY_QUERY
        , UInt, 12
        , UInt, pSTORAGE_DESCRIPTOR_HEADER ;STORAGE_DEVICE_DESCRIPTOR http://bit.ly/O8UNiH
        , UInt, 1024
        , UIntP, BR
        , UInt, 0 )


 BT := NumGet( pSTORAGE_DESCRIPTOR_HEADER + 28 )   ; STORAGE_BUS_TYPE http://bit.ly/T3qt9C
 If ( BT <> 0x7 )                                  ; BusTypeUsb = 0x7
    Return 0,   DllCall( "CloseHandle", UInt,hVol )
  , ErrorLevel := 2                                ; Drive not USB Mass Storage Device!




 IOCTL_STORAGE_GET_DEVICE_NUMBER := 0x2D1080
 pSTORAGE_DEVICE_NUMBER          := &GenBuf


 DllCall( "DeviceIoControl"
        , UInt,  hVol
        , UInt,  IOCTL_STORAGE_GET_DEVICE_NUMBER   ; MSDN http://bit.ly/Ssuzfm
        , UInt,  0
        , UInt,  0
        , UInt,  pSTORAGE_DEVICE_NUMBER            ; MSDN http://bit.ly/PF17hX
        , UInt,  12
        , UIntP, BR
        , UInt,  0   )


 DllCall( "CloseHandle", UInt,hVol )


 If ( BR = 0 )
    Return 0,  ErrorLevel := 3                     ; Unable to ascertain the Device number


 sDevNum := NumGet( pSTORAGE_DEVICE_NUMBER + 4 )


 GUID_DEVINTERFACE_DISK := "{53F56307-B6BF-11D0-94F2-00A0C91EFB8B}" ; http://bit.ly/TXvGlC
 VarSetCapacity( DiskGUID, 16, 0 )
 NumPut( 0x53F56307,   DiskGUID, 0, "UInt"  )  ,  NumPut( 0xB6BF, DiskGUID, 4, "UShort" )
 NumPut( 0x11D0,       DiskGUID, 6, "UShort")  ,  NumPut( 0xF294, DiskGUID, 8, "UShort" )
 NumPut( 0x1EC9A000,   DiskGUID,10, "UInt"  )  ,  NumPut( 0x8BFB, DiskGUID,14, "UShort" )


 hMod := DllCall( "LoadLibrary", Str,"SetupAPI.dll", UInt )


 hDevInfo := DllCall( "SetupAPI\SetupDiGetClassDevs"                ; http://bit.ly/Pf6vHX
                    . ( A_IsUnicode ? "W" : "A" )
                    , UInt,  &DiskGUID
                    , UInt,  0
                    , UInt,  0
                    , UInt,  0x12  ;  DIGCF_PRESENT := 0x2 | DIGCF_DEVICEINTERFACE := 0x10
                          ,  Int )


 If ( hDevInfo < 1 )
    Return 0,  ErrorLevel := 4                    ; No storage class devices were found!




 pSP_DEVICE_INTERFACE_DATA        :=  &GenBuf + 12             ; MSDN http://bit.ly/PJFcbj
 pSP_DEVICE_INTERFACE_DETAIL_DATA :=  &GenBuf + 40             ; MSDN http://bit.ly/SXr3We
 pSP_DEVINFO_DATA                 :=  &GenBuf + 1040           ; MSDN http://bit.ly/Rgp02c




 NumPut( 28, pSP_DEVICE_INTERFACE_DATA + 0 )
 NumPut( 28, pSP_DEVINFO_DATA + 0 )
 NumPut( 4 + ( A_IsUnicode ? 2 : 1 ), pSP_DEVICE_INTERFACE_DETAIL_DATA + 0 )


 DeviceFound := Instance := DeviceNumber := 0


 While DllCall( "SetupAPI\SetupDiEnumDeviceInterfaces"
              , UInt,  hDevInfo
              , UInt,  0
              , UInt,  &DiskGUID
              , UInt,  Instance
              , UInt,  pSP_DEVICE_INTERFACE_DATA ) {


       Instance ++


       DllCall( "SetupAPI\SetupDiGetDeviceInterfaceDetail"     ; MSDN http://bit.ly/NINIci
            . ( A_IsUnicode ? "W" : "A" )
              , UInt,  hDevInfo
              , UInt,  pSP_DEVICE_INTERFACE_DATA               ; MSDN http://bit.ly/PJFcbj
              , UInt,  0
              , UInt,  0
              , UIntP, nBytes
              , UInt,  pSP_DEVINFO_DATA )                      ; MSDN http://bit.ly/Rgp02c




       DllCall( "SetupAPI\SetupDiGetDeviceInterfaceDetail"     ; MSDN http://bit.ly/NINIci
            . ( A_IsUnicode ? "W" : "A" )
              , UInt,  hDevInfo
              , UInt,  pSP_DEVICE_INTERFACE_DATA               ; MSDN http://bit.ly/PJFcbj
              , UInt,  pSP_DEVICE_INTERFACE_DETAIL_DATA        ; MSDN http://bit.ly/SXr3We
              , UInt,  nBytes
              , UInt,  0
              , UInt,  pSP_DEVINFO_DATA )                      ; MSDN http://bit.ly/Rgp02c


      hVol  := DllCall( "CreateFile"
                      , UInt,  pSP_DEVICE_INTERFACE_DETAIL_DATA + 4
                      , UInt,  0 
                      , UInt,  0 
                      , UInt,  0
                      , UInt,  0x3
                      , UInt,  0x0
                      , UInt,  0  )


      If ( hVol < 0 )
           Continue


      DllCall( "DeviceIoControl"
             , UInt,  hVol
             , UInt,  IOCTL_STORAGE_GET_DEVICE_NUMBER          ; MSDN http://bit.ly/Ssuzfm
             , UInt,  0
             , UInt,  0
             , UInt,  pSTORAGE_DEVICE_NUMBER                   ; MSDN http://bit.ly/PF17hX
             , UInt,  12
             , UIntP, BR
             , UInt,  0   )


      DllCall( "CloseHandle", UInt,hVol )


      If ( BR = 0   )
           Continue


      tDevNum := NumGet( pSTORAGE_DEVICE_NUMBER + 4 )
      If DeviceFound := ( tDevNum == sDevnum )
         Break
 }


 If ( DeviceFound = 0 )
    Return 0,  ErrorLevel := 5                  ; No matching storage class devices found!


 DllCall( "SetupAPI\SetupDiGetDeviceRegistryProperty"
      . ( A_IsUnicode ? "W" : "A" )
        , UInt, hDevInfo
        , UInt, pSP_DEVINFO_DATA
        , UInt, 12 ; SPDRP_FRIENDLYNAME
        , UInt, 0
        , Str,  GenBuf
        , UInt, 1024
        , UInt, 0 )


 FRIENDLY := GenBuf
 DllCall( "SetupAPI\SetupDiDestroyDeviceInfoList", UInt,hDevInfo )  ; http://bit.ly/TWTmsN


 DllCall( "SetupAPI\CM_Get_Parent"
        , UIntP, hDeviceID
        , UInt,  NumGet( pSP_DEVINFO_DATA + 20 )
        , UInt,  0 )


 If ( hDeviceID = 0 )
    Return 0,  ErrorLevel := 6                  ; Problem IDentifying USB Device!




 DllCall( "SetupAPI\CM_Get_Device_ID"
      . ( A_IsUnicode ? "W" : "A" )
        , UInt,  hDeviceID
        , Str,   GenBuf
        , UInt,  1024
        , UInt,  0 )


 DeviceID := GenBuf
 MAX_PATH := ( A_IsUnicode ? 520 : 260 )


Label_SafelyRemoveUMS:


 Loop 5 {


          DllCall( "SetupAPI\CM_Request_Device_Eject"
               . ( A_IsUnicode ? "W" : "A" )
                 , UInt,  hDeviceID
                 , UIntP, VetoType
                 , Str,   GenBuf
                 , UInt,  MAX_PATH
                 , Int,   0 )


          If ( VetoType = 0 )
             Break


        }


 If ( Retry && VetoType == 6 ) {                ; PNP_VetoOutstandingOpen = 6


   MsgBox, 0x1035 ; MB_SYSTEMMODAL=0x1000 | MB_ICONEXCLAMATION=0x30 | MB_RETRYCANCEL=0x5
         , Safely Remove USB Mass Storage Drive %Drive%
         , Unable to Eject Drive due to Open File Handles!`n`n%FRIENDLY%`n%DeviceID%


   IfMsgBox Retry, GoTo Label_SafelyRemoveUMS


 }


Return ( VetoType ? 0 : FRIENDLY "`n" DeviceID  )
      , DllCall( "SetLastError", UInt,VetoType )
      , ErrorLevel := VetoType ? 7 : 0
}
